#!/bin/bash
#
# Start a process, check that it is started and returns its PID.
# At the end, returns the PID of the started process or -1 in case of error.
#
# Usage: start.sh -i PIDFILE [-p PRIORITY] [-n NSECS] [-c CWD] [-o OUTFILE] COMMAND
# 
# PIDFILE    : the name of the file where to store the process id (PID)
# PRIORITY   : the priority of the process which is a value between -20 and 19
# NSECS      : wait for NSECS seconds and check that the process is still alive 
# CWD        : current working directory for this process
# OUTFILE    : name of the file where to write the command outputs (absolute path or relative to CWD)
# COMMAND    : command to execute (the executable and these arguments) (absolute path or relative to CWD) 
#

NSECS=0
OUTFILE=/dev/null
NICE=""
PIDFILE=""

# show usage
usage()
{
    echo "Usage: start.sh -i PIDFILE [-p PRIORITY] [-n NSECS] [-c CWD] [-o OUTFILE] COMMAND"
    echo ""
    echo "PIDFILE    : the name of the file where to store the process id (PID)"
    echo "PRIORITY   : the priority of the process which is a value between -20 and 19"
    echo "NSECS      : wait for NSECS seconds and check that the process is still alive "
    echo "CWD        : current working directory for this process"
    echo "OUTFILE    : name of the file where to write the command outputs (absolute path or relative to CWD)"
    echo "COMMAND    : command to execute (the executable and these arguments) (absolute path or relative to CWD)"
    echo ""
    echo "At the end, returns the PID of the started process or -1 in case of error "
}

# analyze options
while getopts ":i:p:n:c:o:" OPT; do
    case ${OPT} in
    i)  PIDFILE=${OPTARG}
        echo "PIDFILE set to ${PIDFILE}"
        ;;
    
    p)  echo "PRIORITY set to '${OPTARG}'"
    
        case ${OPTARG} in
        "low")
            NICE_LEVEL=19;;
        "belownormal")  
            NICE_LEVEL=10;;
        "normal")       
            NICE_LEVEL=0;;
        "abovenormal")
            NICE_LEVEL=-5;;
        "high")
            NICE_LEVEL=-10;;     
        "realtime")
            NICE_LEVEL=-20;;
        *)
            echo "Unknown '${OPTARG}' value for PRIORITY.\nPRIORITY is set to 'normal'"
            NICE_LEVEL=0;;
        esac

        NICE="nice -n ${NICE_LEVEL} "
        ;;
        
    n)  NSECS=${OPTARG}
        echo "NSECS set to ${NSECS}"
        ;;
        
    c)  CWD=${OPTARG}
        echo "CWD set to ${OPTARG}"
        cd ${OPTARG}
        ;;
        
    o)  OUTFILE=${OPTARG}
        echo "OUTFILE set to ${OUTFILE}"
        ;;
       
    \?) echo "Error: Invalid option -${OPTARG}"
        exit -1
        ;;
        
    :)  echo "Error: Option ${OPTARG} requires an argument."
        exit -1
        ;;

    esac
done

# remove processed options from the list of arguments
shift $(( OPTIND - 1 ));

# check if the PID file can be created or not
touch ${PIDFILE} > /dev/null 2>&1
if [ ! -f ${PIDFILE} ];
then
    echo "Error: the PID file ${PIDFILE} is not valid"
    exit -1
fi

# if the output file already exists, backup it
if [ -f ${OUTFILE} ];
then
    mv ${OUTFILE} ${OUTFILE}.$(date +"%m_%d_%Y-%H_%M_%S")
fi

# start the process
echo "COMMAND: ${NICE} $* > ${OUTFILE}"
${NICE} $* > ${OUTFILE} 2>&1 &
PID=$!

if [ -z ${PID} ];
then
    echo "The process is not started"
    exit -1
fi

# wait for NSECS seconds and check if the process is still alive
sleep ${NSECS}

if ! ps -p ${PID} >/dev/null 2>&1
then
    echo "The process is not running (PID:${PID})"
    exit -1
fi

echo $PID > ${PIDFILE}
exit 0
