#! /bin/bash

mvn clean resources:resources package

if [ -d "installer" ]; then
    rm -rf ./installer
fi

chmod +x ./target/*installer.jar

