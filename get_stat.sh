#!/bin/sh

stat=$1

dirs=`find . -type d -name '[0-9]*'  | sed -e 's/^\.\///' | sort -n`
for dir in $dirs ;do
  if [ -e $dir/stats.json ] ;then
    cat $dir/stats.json | jq .$stat 2>/dev/null
  fi
done
