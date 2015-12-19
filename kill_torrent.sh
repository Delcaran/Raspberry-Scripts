#!/bin/bash
date
source /home/pi/scripts/config.sh
if [ -e $PID ]
then
    echo "transmission attivo: salvo la coda"
	#python /home/pi/scripts/toggle_torrent.py stop
	echo "fermo transmission"
	count=$(ps x | grep -ic 'transmission')
	while [[ $count > 1 ]]
	do
		/usr/local/bin/transmission-remote $HOST:$PORT -n $USERNAME:$PASSWORD --exit
		sleep 1s
		echo "aspetto chiusura transmission"
		count=$(ps x | grep -ic 'transmission')
	done
	echo "transmission fermato"
    rm $PID
else
    echo "transmission non attivo"
fi

date
echo ""

exit 0
