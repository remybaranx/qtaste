#!/bin/bash

source "$(dirname "$0")/common.sh"

start_qtaste_without_test_api 64m 512m com.qspin.qtaste.util.GenerateTestCampaignDoc 2>&1 $*
