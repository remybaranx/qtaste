@echo off
setlocal

call common.bat

java -Xms64m -Xmx512m -cp "%QTASTE_CLASSPATH%";testapi/target/qtaste-testapi-deploy.jar com.qspin.qtaste.kernel.engine.TestEngine %* | set result=1
if %result% == 1
then
    echo test failed
fi
endlocal
