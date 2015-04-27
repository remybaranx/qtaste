#!/bin/bash

source "$(dirname "$0")/common.sh"

start_qtaste_without_test_api 64m 512m com.qspin.qtaste.util.GenerateTestSuitesDoc 2>&1 $*
