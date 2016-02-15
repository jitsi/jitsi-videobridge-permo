#!/bin/bash

if [ -z "$1" ] ;then
    echo "Usage: $0 <version>" >&2
    exit 1
fi

VERSION=$1
DATA_FILE="${VERSION}/data.json"

# Take an array of numbers and produce its basic statistics.
JQ_CALC_STATS=`cat<<"END"
min as $min |
max as $max |
(reduce .[] as $s (0; . + $s)) as $sum |
($sum/length) as $mean |
length as $length |
((reduce .[] as $s (0; . + ($s - $mean)*($s-$mean))) | . / $length | sqrt) as $sd |
{sum: $sum,  min: $min, max: $max, length: length, mean: $mean, sd: $sd}
END
`

JQ_PRINT_STATS="\"$VERSION\", .mean, .sd, .min, .max"

br_mbps_stats=`cat $DATA_FILE | jq -s "map(((.colibri.bit_rate_download | tonumber) + (.colibri.bit_rate_upload | tonumber)) / 1000) | ${JQ_CALC_STATS}"`
echo "Bitrate:" >&2
echo $br_mbps_stats | jq . >&2

scale_factor=`echo $br_mbps_stats | jq "(if .mean == 0 then 0 else 100 / .mean end)" `
echo "Scale factor: $scale_factor" >&2

cpu_stats=`cat $DATA_FILE | jq -s "map(.colibri.cpu_usage | tonumber | 100 * . * $scale_factor) | ${JQ_CALC_STATS}"`
echo "CPU usage:" >&2
echo $cpu_stats | jq . >&2

threads_stats=`cat $DATA_FILE | jq -s "map(.colibri.threads | tonumber) | ${JQ_CALC_STATS}"`
mem_stats=`cat $DATA_FILE | jq -s "map(.mem_ps | tonumber | . / 1000) | ${JQ_CALC_STATS}"`
echo "Threads:" >&2
echo $threads_stats | jq . >&2

echo $cpu_stats | jq "$JQ_PRINT_STATS" | tr '\n' ' ' >> cpu.data
echo >> cpu.data
echo $br_mbps_stats | jq "$JQ_PRINT_STATS" | tr '\n' ' ' >> br_mbps.data
echo >> br_mbps.data
echo $threads_stats | jq "$JQ_PRINT_STATS" | tr '\n' ' ' >> threads.data
echo >> threads.data
echo $mem_stats | jq "$JQ_PRINT_STATS" | tr '\n' ' ' >> mem_rss.data
echo >> mem_rss.data
