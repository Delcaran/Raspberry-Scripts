#!/bin/bash
H=$(date +%H)
if (( 1 <= 10#$H && 10#$H < 8 )); then
    echo "Verifico che sia acceso"
    /home/pi/scripts/start_torrent.sh
else
    echo "Verifico che sia spento"
    /home/pi/scripts/stop_torrent.sh
fi
