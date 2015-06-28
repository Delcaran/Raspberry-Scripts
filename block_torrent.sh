#!/bin/bash

source /home/pi/scripts/config.sh

if [ ! -f $BLOCK_TORRENT_FILE ]
then
    touch $BLOCK_TORRENT_FILE
fi

exit 0
