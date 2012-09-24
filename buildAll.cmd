@echo off
echo Compiling the kernel ...
pushd kernel
call build.cmd
popd

echo Compiling other stuff ...
call mvn install

echo Compiling plugins ...
pushd plugins
call build.cmd
popd

echo Compiling demos ...
pushd demo
call build.cmd
popd