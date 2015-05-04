@echo off
setlocal

call common.bat

java -Xms64m -Xmx1024m -cp "%QTASTE_CLASSPATH%";testapi/target/qtaste-testapi-deploy.jar com.qspin.qtaste.ui.MainPanel %*
endlocal
