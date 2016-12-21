#!/bin/bash
set -x
JVB_VERSION_NAME=`dpkg -s jitsi-videobridge | grep Version | awk '{print $2}' | cut -d'-' -f1`
JICOFO_VERSION_NAME=`dpkg -s jicofo | grep Version | awk '{print $2}' | cut -d'-' -f2`
JITSI_MEET_VERSION_NAME=`dpkg -s jitsi-meet-web | grep Version | awk '{print $2}' | cut -d'.' -f3 | cut -d'-' -f1`
PIPELINE_BUILD_NUMBER=$1

VERSION_STR="${PIPELINE_BUILD_NUMBER}_${JVB_VERSION_NAME}_${JICOFO_VERSION_NAME}_${JITSI_MEET_VERSION_NAME}"

if [ -d "$VERSION_STR" ]; then
    #do nothing here since directory already exists
    rm -rf $VERSION_STR
fi
mkdir $VERSION_STR
./collect-stats.sh 2>/dev/null > $VERSION_STR/data.json
