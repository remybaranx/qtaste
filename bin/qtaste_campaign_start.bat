@echo off
setlocal

call common.bat

java -Xms64m -Xmx512m -cp "%QTASTE_CLASSPATH%";testapi/target/qtaste-testapi-deploy.jar com.qspin.qtaste.kernel.campaign.CampaignLauncher %*
endlocal
