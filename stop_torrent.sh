#!/bin/bash
date
source /home/pi/scripts/config.sh
if [ `pgrep transmission` ]
then
#	echo "transmission attivo: salvo la coda"
#    python /home/pi/scripts/toggle_torrent.py stop
    echo "fermo transmission"
    /usr/local/bin/transmission-remote $HOST:$PORT -n $USERNAME:$PASSWORD --exit
    echo "transmission fermato"
else
	echo "transmission non attivo"
fi

while [ `pgrep transmission` ]
do
    echo "aspetto chiusura transmission"
    sleep 1s
done

if [ -e $PID ]
then
	rm $PID
fi

if [ `pgrep openvpn` ]
then
    echo "vpn attiva"
    sudo service openvpn stop
else
    echo "vpn non attiva"
#    sudo service openvpn start
fi

echo "avvio transmission su interfaccia di loopback"
/usr/local/bin/transmission-daemon --bind-address-ipv4 127.0.0.1 -x $PID
#while [ -z "`ss -l | grep 19091`" ]
#do
#    echo "aspetto rpc transmission"
#    sleep 1s
#done
#python /home/pi/scripts/toggle_torrent.py start

date
echo ""

exit 0
