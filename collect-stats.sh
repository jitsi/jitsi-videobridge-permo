#!/bin/bash

# Number of participants/hammers to expect
NUM_HAMMERS=0
# Wait for up to TIMEOUT seconds for at least NUM_HAMMERS participants to connect.
TIMEOUT=8

DATA_POINTS=200
INTERVAL_S=1

function getColibriStats() {
    curl http://localhost:8080/colibri/stats 2>/dev/null
}

function getEnrichedStats()
{
    stats=`getColibriStats`
    r=$?
    if [ $r -ne "0" ] ;then
        echo "Failed to get colibri stats: $r" >&2
        return
    fi
        
    top_cpu=`top -n1 -b | head -3 | tail -1`
    top_us=`echo $top_cpu | awk '{print $2}'`
    top_sy=`echo $top_cpu | awk '{print $4}'`
    top_ni=`echo $top_cpu | awk '{print $6}'`
    top_wa=`echo $top_cpu | awk '{print $10}'`
    top_combined=`echo $cpu_top_us $cpu_top_sy $cpu_top_ni $cpu_top_wa | awk '{print $1 + $2 + $3 + $4}'`

    mem_ps=`ps u $jvb_java_pid | tail -1 | awk '{print $6}'` #RSS
    mem_pmap=`pmap -d $jvb_java_pid | tail -n 1 | awk '{print $4}' | tr -d K`
    mem_total=`free -m | head -2 | tail -1 | awk '{print $3}'`


    #run ifstat as a separate process with output in ..../ifstat.out
    #in_out_kbps=`tail -n 1 /home/users/boris/ifstat.out`
    #network_in_kbps=`echo $in_out_kbps | awk '{print $1}'`
    #network_out_kbps=`echo $in_out_kbps | awk '{print $2}'`

    load_avg=`cat /proc/loadavg | awk '{print $1}'`
    timestamp=`date +%s`

    jq -n "{colibri: $stats, \
            top_us: $top_us, \
            top_sy: $top_sy, \
            top_ni: $top_ni, \
            top_wa: $top_wa, \
            top_combined: $top_combined, \
            mem_ps: $mem_ps, \
            mem_pmam: $mem_pmap, \
            mem_total: $mem_total, \
            load_avg: $load_avg, \
            timestamp: $timestamp}"
}


timeout=$TIMEOUT
while [ ! $timeout -eq 0 ] ;do
    timeout=$(($timeout-1))
    
    participants=$(getColibriStats | jq .participants)
    if [ -z $participants ]; then participants=0; fi

    if [ $participants -ge $NUM_HAMMERS ]; then
        break
    fi
    
    echo "Not enough participants yet: $participants" >&2
    sleep 1
done

if [ $timeout -eq 0 ] ;then 
    echo "Giving up." >&2
    exit 1
fi

echo "Sufficient number of participants connected: $participants. Proceeding." >&2


jvb_java_pid=`ps ax | grep jitsi-videobridge | grep -v grep | grep -v jvb.sh | awk '{print $1}' `
for i in `eval echo "{1..$DATA_POINTS}"` ;do
    getEnrichedStats
    echo "Getting stats ${i}/${DATA_POINTS}" >&2
    sleep $INTERVAL_S
done

