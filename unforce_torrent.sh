#!/bin/bash

source /home/pi/scripts/config.sh

if [ -f $FORCE_TORRENT_FILE ]
then
    rm $FORCE_TORRENT_FILE
fi

exit 0
