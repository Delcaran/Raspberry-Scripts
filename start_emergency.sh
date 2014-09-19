#!/bin/bash
source /home/pi/scripts/config.sh
INSTANCES=$(pgrep transmission | wc -l)
if [ "$INSTANCES" -gt "0" ]
then
	echo "transmission attivo: salvo la coda"
    python /home/pi/scripts/toggle_torrent.py stop
    echo "fermo transmission"
    while [ "$INSTANCES" -gt "0" ]
    do
        /usr/local/bin/transmission-remote $HOST:$PORT -n $USERNAME:$PASSWORD --exit
        sleep 1s
        INSTANCES=$(pgrep transmission | wc -l)
        echo "aspetto chiusura transmission"
    done
	echo "transmission fermato"
else
	echo "transmission non attivo"
fi

sudo killall --wait transmission-daemon
rm $PID

sudo kill -s 9 `lsof -t +D /home/pi/hdd1/`
sudo umount /home/pi/hdd1

sudo kill -s 9 `lsof -t +D /home/pi/hdd2/`
sudo umount /home/pi/hdd2
