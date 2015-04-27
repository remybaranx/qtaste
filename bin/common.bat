@echo off
set QTASTE_ROOT=%~dp0\..
set QTASTE_JYTHON_SCRIPTS=%QTASTE_ROOT%\tools\jython\QTasteScripts
set QTASTE_CLASSPATH=%QTASTE_ROOT%\plugins\*:%QTASTE_ROOT%\kernel\target\qtaste-kernel-deploy.jar"
set JYTHONPATH=%QTASTE_JYTHON_SCRIPTS%:%QTASTE_JYTHON_SCRIPTS%/TestScriptDoc:%QTASTE_JYTHON_SCRIPTS%/TestProcedureDoc"

