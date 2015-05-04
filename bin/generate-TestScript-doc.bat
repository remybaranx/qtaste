@echo off

if [%1] == [] (
  goto usage
)
if not [%2] == [] (
  goto usage
)

goto begin

:usage
echo Usage: %~n0 ^<TestScriptFile^>
goto end

:begin

call common.bat

java -Xms64m -Xmx512m -cp "%QTASTE_CLASSPATH%";testapi\target\qtaste-testapi-deploy.jar com.qspin.qtaste.util.GenerateTestScriptDoc %*
