#!/bin/sh

if [ -z "$1" ] ;then
    echo "Usage: $0 <version>" >&2
    exit 1
fi

VERSION=$1

./crunch.sh $VERSION

# for plot in plot plot2 ;do
#     cat ${plot}.template \
#         | sed -e "s/VERSION_START/$(($VERSION-20))/g" \
#         | sed -e "s/VERSION_END/$(($VERSION+1))/g" \
#         | sed -e "s/FILENAME/${VERSION}\/${plot}.pdf/g" \
#         > $VERSION/${plot}.plot
    
#     gnuplot ${VERSION}/${plot}.plot
# done


rm -f latest
ln -s $VERSION latest
