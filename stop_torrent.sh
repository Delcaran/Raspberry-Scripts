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

if [ `pgrep openvpn` ]
then
    echo "vpn attiva"
    sudo service openvpn stop
else
    echo "vpn non attiva"
fi

echo "avvio transmission su interfaccia di loopback"
/usr/local/bin/transmission-daemon --bind-address-ipv4 127.0.0.1 -x $PID
while [ -z "`ss -l | grep 19091`" ]
do
    echo "aspetto rpc transmission"
    sleep 1s
done
#python /home/pi/scripts/toggle_torrent.py start

date
echo ""

exit 0
