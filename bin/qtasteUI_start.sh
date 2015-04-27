#!/bin/bash
#
# Start QTaste with its GUI with the following settings :
# - initial memory allocation pool size (Xms) : 64M
# - maximum memory allocation pool size (Xmx) : 1024M
#

source "$(dirname "$0")/common.sh"

start_qtaste 64m 1024m com.qspin.qtaste.ui.MainPanel $*
