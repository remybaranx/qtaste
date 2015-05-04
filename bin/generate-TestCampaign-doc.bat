@echo off
setlocal enableDelayedExpansion 

call common.bat

java -Xms64m -Xmx512m -cp "%QTASTE_CLASSPATH%" com.qspin.qtaste.util.GenerateTestCampaignDoc 2>&1 %*

endlocal
