#!/bin/bash
#
# Stop a process with a PID file.
#
# Usage: stop.sh PIDFILE
#

# show usage
usage()
{
    echo "Stop a process with a PID file."
    echo "Usage: stop.sh PIDFILE"
    echo ""
}

# sanity checks
if [ $# -ne 1 ];
then
    usage
    echo "Error: invalid number of arguments"
    exit -1
fi

# extract arguments
PIDFILE=$1

if [ -f ${PIDFILE} ];
then
    PID=$(cat ${PIDFILE})
    rm ${PIDFILE}
else
    echo "Error: unable to retrieve the process PID using the file ${PIDFILE}"
    exit -1
fi

# check if the process is still alive
if ! ps -p ${PID} > /dev/null 2>&1
then
    echo "The process is already stopped (PID:${PID})"
    exit 0
fi

# first, try to stop the process (send SIGTERM signal)
for (( i = 0 ; i < 5 ; i++ )) do
    kill -TERM ${PID} > /dev/null 2>&1

    if ! ps -p ${PID} > /dev/null 2>&1
    then
        echo "The process has been stopped (PID:${PID})"
        exit 0
    fi
done

# if the process is still alive, kill it
kill -KILL ${PID} > /dev/null 2>&1

if ! ps -p ${PID} > /dev/null 2>&1
then
    echo "The process has been killed (PID:${PID})"
    exit 0
else
    echo "Error: unable to kill the process (PID:${PID})"
    exit -1
fi
