#!/bin/bash
#
# This script looks for .test files, launch them and check the results. 
# Usage: testAll.sh [<TEST_LIST_DIR>]
#   - TEST_LIST_DIR : a directory which contains some .test files
#

#---------------------------------------------------------
# GLOBAL VARIABLES
#---------------------------------------------------------

# QTASTE variables
QTASTE_ROOT=$(cd $(dirname "$0")/..; pwd -P)
QTASTE_TEST_ROOT=${QTASTE_ROOT}/tests
QTASTE_BIN=${QTASTE_ROOT}/bin/qtaste_start.sh
ENGINE_CONF=${QTASTE_TEST_ROOT}/conf/engine.xml
TEST_OUTPUT_DIR=${QTASTE_TEST_ROOT}/output
TEST_LIST_DIR=
GLOBAL_TEST_SUCCESS=0

echo "QTASTE_ROOT: ${QTASTE_ROOT}"
echo "QTASTE_TEST_ROOT: ${QTASTE_TEST_ROOT}"
echo ""

# COLORS
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

#---------------------------------------------------------
# FUNCTIONS
#---------------------------------------------------------

# this function hide what is written on STDOUT and STDERR
function quiet()
{
    $* > /dev/null 2>&1
    return $?
}

# print a message as an error
function print_error()
{
    echo -e "${RED}ERROR: $*${NC}"
}

# print a message as a warning
function print_warning()
{
    echo -e "${YELLOW}WARN: $*${NC}"
}

# compare log-results.xml files (generated and expected) 
# and return 0 if the files are the same, 1 otherwise.
# Param: the TESTNAME
function default_check_result()
{
    # sanity checks
    if [ $# -ne 1 ]
    then
        return 1
    fi
    
    TESTNAME=$1
    
    TEST_RESULT=${TEST_OUTPUT_DIR}/${TESTNAME}/log-results.xml
    EXPECTED_RESULT=${TEST_LIST_DIR}/${TESTNAME}_results.xml
    
    # compare the log-result.xml file with the expected one
    quiet diff ${TEST_RESULT} ${EXPECTED_RESULT}
    return $?
}

# compare step results files (generated and expected) 
# and return 0 if the files are the same, 1 otherwise.
# Param: the TESTNAME
function check_steps_result()
{
    # sanity checks
    if [ $# -ne 1 ]
    then
        return 1
    fi

    # check if the steps result file exists
    if [ ! -f ${TEST_LIST_DIR}/${TESTNAME}_steps_result.txt ]
    then
        return 1
    fi
    
    # check files
    cat ${TEST_OUTPUT_DIR}/$1/log-results.xml | sed -n 's|.*result=\"\(.*\)\".*|\1|p' | diff ${TEST_LIST_DIR}/${TESTNAME}_steps_result.txt -
    
    return $?
}

# compare output.log files (generated and expected) 
# and return 0 if the files are the same, 1 otherwise.
# Param: the TESTNAME
function check_output_log()
{
    # sanity checks
    if [ $# -ne 1 ]
    then
        return 1
    fi
    
    TESTNAME=$1
    
    TEST_RESULT=${TEST_OUTPUT_DIR}/${TESTNAME}/output.log
    EXPECTED_RESULT=${TEST_LIST_DIR}/${TESTNAME}_output.log
    
    # compare the log-result.xml file with the expected one
    quiet diff ${TEST_RESULT} ${EXPECTED_RESULT}
    return $?
}

# run a test
# Param: 
#   - TESTNAME
#   - TESTDIR
#   - TESTBED
#   - TESTSUITE
#   - TESTFUNC
#   - TESTTIMEOUT
function run_test()
{
    # sanity checks
    if [ $# -ne 6 ];
    then
        printf '%-60s %-20s\n' ${TESTNAME} "${RED}[FATAL]${NC}"
    fi
    
    TESTNAME=$1
    TESTDIR=$2
    TESTBED=$3
    TESTSUITE=$4
    TESTFUNC=$5
    TESTTIMEOUT=$6

    TEST_SUCCESS=0

    # prepare the output directory
    quiet mkdir -p "${TEST_OUTPUT_DIR}/${TESTNAME}"

    # move into the test directory
    quiet pushd ${TESTDIR}

    # clean logs and reports
    quiet rm -r log/*
    quiet rm -r reports/*
        
    # run the test in the correct directory
    ${QTASTE_BIN} -engine ${ENGINE_CONF} -testbed Testbeds/${TESTBED} -testsuite TestSuites/${TESTSUITE} > ${TEST_OUTPUT_DIR}/${TESTNAME}/output.log 2>&1 &
    PID=$!
    
    # process timeout management
    ELAPSED_TIME=0
    while quiet ps -p ${PID} && [ ${ELAPSED_TIME} -lt ${TESTTIMEOUT} ]
    do
        sleep 1
        ELAPSED_TIME=$((${ELAPSED_TIME} + 1))
    done
    
    # backup reports and logs
    quiet find reports -name "log-results*.xml" -exec cp {} "${TEST_OUTPUT_DIR}/${TESTNAME}/log-results.xml" \;
    quiet cp log/* "${TEST_OUTPUT_DIR}/${TESTNAME}"

    quiet popd

    # if the timeout has been reached, kill the process and exit without checking results
    if [ ${ELAPSED_TIME} -ge ${TESTTIMEOUT} ]
    then
        quiet kill -9 ${PID}
        printf '%-60s %-20s\n' ${TESTNAME} "${YELLOW}[TIMEOUT]${NC}"
        return
    fi

    # call the check result functions
    FUNCTIONS=$(echo ${TESTFUNC} | tr ";" "\n")
    
    for FUNC in ${FUNCTIONS}
    do            
        # check that it's really a function
        if ! type ${FUNC} | grep -e ".*function.*" > /dev/null 2>&1
        then
            printf '%-60s %-20s\n' "->  ${FUNC}" "${RED}[FAILURE]${NC}"
            TEST_SUCCESS=1
            continue
        fi

        ${FUNC} ${TESTNAME}

        if [ $? -eq 0 ]
        then
            printf '%-60s %-20s\n' "->  ${FUNC}" "${GREEN}[SUCCESS]${NC}"
        else
            printf '%-60s %-20s\n' "->  ${FUNC}" "${RED}[FAILURE]${NC}"
            TEST_SUCCESS=1
        fi
        
    done 

    if [ ${TEST_SUCCESS} -eq 0 ]
    then
        printf '%-60s %-20s\n' ${TESTNAME} "${GREEN}[SUCCESS]${NC}"
    else
        printf '%-60s %-20s\n' ${TESTNAME} "${RED}[FAILURE]${NC}"
        GLOBAL_TEST_SUCCESS=1
    fi
}

#---------------------------------------------------------
# MAIN
#---------------------------------------------------------

# parse arguments
if [ $# -eq 1 ]
then
    TEST_LIST_DIR=$1
fi

# if no TEST_LIST_DIR has been set, use the default one
if [ -z ${TEST_LIST_DIR} ]
then
    TEST_LIST_DIR=${QTASTE_TEST_ROOT}/tests
    print_warning "Use ${TEST_LIST_DIR} as default tests directory"
fi

# prepare the output directory
if [ -d ${TEST_OUTPUT_DIR} ];
then
    rm -r ${TEST_OUTPUT_DIR}
fi

mkdir ${TEST_OUTPUT_DIR}

# extract all test files from TEST_LIST_DIR
TEST_FILES=$(find ${TEST_LIST_DIR} -name "*.test")
TEST_FILES_COUNT=$(find ${TEST_LIST_DIR} -name "*.test" | wc -l)

echo "${TEST_FILES_COUNT} tests found in ${TEST_LIST_DIR}"

# launch every tests
for TESTFILE in ${TEST_FILES}
do
    TESTNAME=$(dirname "${TESTFILE}")/$(basename "${TESTFILE}" .test)
    TESTBED=
    TESTSUITE=
    TESTDIR=
    TESTFUNC=
    TESTTIMEOUT=

    # remove the TEST_LIST_DIR at the beginning of the TEST NAME
    TESTNAME=$(echo ${TESTNAME} | sed "s|${TEST_LIST_DIR}||g")
    
    # include the test file
    source ${TESTFILE}

    # check TESTDIR variable
    if [ -z ${TESTDIR} ];
    then
        print_warning "No TESTDIR defined. Use default test directory ${QTASTE_ROOT}"
        TESTDIR=${QTASTE_ROOT}
    else
        TESTDIR=${QTASTE_ROOT}/${TESTDIR}
    fi

    if [ ! -d ${TESTDIR} ];
    then
        print_warning "${TESTDIR} does not exist ! Ignore this test (${TESTNAME})."
        continue
    fi

    # check TESTBED variable
    if [ -z ${TESTBED} ];
    then
        print_warning "No TESTBED defined. Ignore this test (${TESTNAME})."
        continue
    fi

    if [ ! -f ${TESTDIR}/Testbeds/${TESTBED} ];
    then
        print_warning "${TESTBED} not found in '${TESTDIR}/Testbeds'. Ignore this test (${TESTNAME})."
        continue
    fi

    # check TESTSUITE variable
    if [ -z ${TESTSUITE} ];
    then
        print_warning "No TESTSUITE defined. Ignore this test (${TESTNAME})."
        continue
    fi
    
    if [ ! -d ${TESTDIR}/TestSuites/${TESTSUITE} ];
    then
        print_warning "${TESTSUITE} not found in '${TESTDIR}/TestSuites'. Ignore this test (${TESTNAME})."
        continue
    fi
    
    # check TESTTIMEOUT variable
    if [ -s ${TESTTIMEOUT} ]
    then
        TESTTIMEOUT=300
    fi

    # check TESTFUNC variable
    if [ -z ${TESTFUNC} ];
    then
        TESTFUNC=default_check_result
    fi

    # run the test
    run_test ${TESTNAME} ${TESTDIR} ${TESTBED} ${TESTSUITE} ${TESTFUNC} ${TESTTIMEOUT}
done

exit ${GLOBAL_TEST_SUCCESS}
