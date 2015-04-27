#!/bin/bash

source "$(dirname "$0")/common.sh"

start_qtaste 64m 512m com.qspin.qtaste.util.GenerateTestSuiteDoc 2>&1 $*
