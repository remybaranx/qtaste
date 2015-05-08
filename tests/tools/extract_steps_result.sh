#!/bin/bash
#
#
#

if [ $# -ne 1 ]
then
    echo "usage: $0 <LOG_RESULT FILE>"
    exit 1
fi

TEST_FILE=$1

if [ ! -f ${TEST_FILE} ]
then
    echo "${TEST_FILE} not found"
    exit 1
fi

cat ${TEST_FILE} | sed -n 's|.*result=\"\(.*\)\".*|\1|p'
