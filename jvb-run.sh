JVB_VERSION=`dpkg -s jitsi-videobridge | grep Version | awk '{print $2}' | cut -d'-' -f1`

mkdir $JVB_VERSION
./collect-stats.sh &2>/dev/null > $JVB_VERSION/data.json
