#!/bin/bash
date
source /home/pi/scripts/config.sh
if [ -e $PID ]
then
    #echo "Transmission attivo: salvo la coda"
	#python /home/pi/scripts/toggle_torrent.py stop
	count=$(ps x | grep -ic 'transmission')
	echo -n "Aspetto chiusura Transmission "
	while [[ $count > 1 ]]
	do
		/usr/local/bin/transmission-remote $HOST:$PORT -n $USERNAME:$PASSWORD --exit &>/dev/null
		sleep 1s
		echo -n "."
		count=$(ps x | grep -ic 'transmission')
	done
	echo " OK"
    rm $PID &>/dev/null
else
    echo "Transmission non attivo."
fi

if [ `pgrep openvpn` ]
then
    echo "VPN attiva."
    sudo systemctl stop openvpn@airvpn.service
else
    echo "VPN non attiva."
fi

echo "Avvio Transmission su interfaccia di loopback."
/usr/local/bin/transmission-daemon --bind-address-ipv4 127.0.0.1 -x $PID &>/dev/null
echo -n "Aspetto RPC Transmission "
while [ -z "`ss -l | grep 19091`" ]
do
    echo -n "."
    sleep 1s
done
echo " OK"
#python /home/pi/scripts/toggle_torrent.py start

date
echo ""

exit 0
