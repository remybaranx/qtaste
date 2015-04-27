#!/bin/bash

#remove previous python compilation classes.
pushd ../tools/jython/QTasteScripts
find . -name "*.class" -exec rm -f {} \;
popd

mvn install -P qtaste-build-kernel-first || exit 1

# restore pom.xml if modified
mv -f pom.xml.bak pom.xml >& /dev/null

exit 0
