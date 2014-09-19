#!/bin/bash
#TR_TORRENT_DIR="/home/pi/hdd2/torrent/completi/serie/fringe/"
#TR_TORRENT_ID=43
#TR_TORRENT_NAME="Fringe.S04.DVDRip.XviD-REWARD"
source /home/pi/scripts/config.sh

#Directory is "$TR_TORRENT_DIR"
#Torrent Name is "$TR_TORRENT_NAME"
#Torrent ID is "$TR_TORRENT_ID"
#Torrent Hash is "$TR_TORRENT_HASH"

#python $SCRIPT "$TR_TORRENT_NAME" "$TR_TORRENT_DIR" "$TR_TORRENT_ID"
python $SCRIPT "$TR_TORRENT_NAME"

/home/pi/scripts/download_subs.sh "$TR_TORRENT_DIR" 1

exit 0
