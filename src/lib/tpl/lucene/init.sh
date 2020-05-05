#!/bin/bash

# for event loop
if [ -z $(pgrep tail) ] ; then
    . /usr/local/bin/loop.sh
fi

if [ "${JAVA_SERVER_START}" == "1" ] ; then
    cd "${JAVA_SERVER_PATH}"
    pkill java > /dev/null 2>&1
    exec java -jar ./ilServer.jar /config/ilServer.ini start
fi

if [ "${JAVA_SERVER_START}" == "0" ] ; then
    pkill java > /dev/null 2>&1
fi
