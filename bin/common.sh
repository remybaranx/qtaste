#!/bin/bash
#
# Common header for all QTaste bash scripts.
#

export QTASTE_ROOT="$(dirname "$0")/.."
export QTASTE_JYTHON_SCRIPTS="${QTASTE_ROOT}/tools/jython/QTasteScripts"
export QTASTE_CLASSPATH="${QTASTE_ROOT}/plugins/*:${QTASTE_ROOT}/kernel/target/qtaste-kernel-deploy.jar"
export JYTHONPATH="${QTASTE_JYTHON_SCRIPTS}:${QTASTE_JYTHON_SCRIPTS}/TestScriptDoc:${QTASTE_JYTHON_SCRIPTS}/TestProcedureDoc"

#
# Start QTaste without the testapi
# @param $1: the XMS value for the JVM (for example, 64m)
# @param $2: the XMX value for the JVM (for example, 512m)
# @param $3: the main class
# @remarks
# - the classpath is set to $QTASTE_CLASSPATH, so if you need to add something to the classpath, add it to $QTASTE_CLASSPATH
#   before calling start_qtaste functions.
# - extra arguments are passed to QTaste.
#
start_qtaste_without_test_api()
{
    EXPECTED_PARAM_COUNT=3

    # check parameters
    if [ $# -lt ${EXPECTED_PARAM_COUNT} ];
    then
        echo "Illegal number of parameters (expected:${EXPECTED_PARAM_COUNT} got:$#)"
        return -1
    fi

    # extract parameters
    XMS_VALUE=$1
    XMX_VALUE=$2
    MAIN_CLASS=$3

    shift ${EXPECTED_PARAM_COUNT}

    # start QTaste
    java -Xms${XMS_VALUE} -Xmx${XMX_VALUE} -cp ${QTASTE_CLASSPATH} ${MAIN_CLASS} $*
}

#
# Start QTaste with testapi
# see documentation of start_qtaste_without_testapi
#
start_qtaste()
{
    export QTASTE_CLASSPATH="${QTASTE_CLASSPATH}:testapi/target/qtaste-testapi-deploy.jar"
    start_qtaste_without_test_api $*
}
