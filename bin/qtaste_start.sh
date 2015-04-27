#!/bin/bash
#
# Start QTaste in console mode with the following settings :
# - initial memory allocation pool size (Xms) : 64M
# - maximum memory allocation pool size (Xmx) : 512M
#

source "$(dirname "$0")/common.sh"

start_qtaste 64m 512m com.qspin.qtaste.kernel.engine.TestEngine 2>&1 $*
exit $?
