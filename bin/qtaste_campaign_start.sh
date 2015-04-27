#!/bin/bash

source "$(dirname "$0")/common.sh"

start_qtaste 64m 512m com.qspin.qtaste.kernel.campaign.CampaignLauncher 2>&1 $*
exit $?
