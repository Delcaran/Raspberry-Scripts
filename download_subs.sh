#!/bin/bash

source /home/pi/scripts/config.sh

function download {
    #PROVIDERS="opensubtitles, tvsubtitles, podnapisi, addic7ed, bierdopje, thesubdb"
    PROVIDERS="opensubtitles, addic7ed, thesubdb"
    LANGUAGES="en"
    OPTIONS=$1
    /usr/local/bin/subliminal --cache-file $CACHE -m 5\
        --languages $LANGUAGES --providers $PROVIDERS ${OPTIONS} -- .
}

OPTIONS=""
ENTERDIR=""

case $# in
    0) ENTERDIR="$BASE_SERIES_DIR" ;;
    1) ENTERDIR="$1" ;;
    2)
        ENTERDIR="$1"
        OPTIONS="--age 1w"
        ;;
esac

cd "$ENTERDIR"
download "$OPTIONS"
for dir in *
do
    if [ -d "$dir" ]
    then
        cd "$dir"
        download "$OPTIONS"
        cd ..
    fi
done

exit 0
