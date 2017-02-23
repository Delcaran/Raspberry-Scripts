#!/bin/bash

source /home/pi/scripts/config.sh
#subliminal --opensubtitles delcaran uP4zmEHPBp7dzac3sbQo download -l en -r tvdb .
function download {
    OPENSUB_USER="delcaran"
    OPENSUB_PASS="uP4zmEHPBp7dzac3sbQo"
    PROVIDERS="opensubtitles"
    LANGUAGES="en"
    OPTIONS=$1
    /usr/local/bin/subliminal --opensubtitles ${OPENSUB_USER} ${OPENSUB_PASS} \
        -l $LANGUAGES --providers $PROVIDERS ${OPTIONS} -r tvdb .
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
