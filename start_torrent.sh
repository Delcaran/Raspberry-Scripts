#!/bin/bash
date
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

if [ `pgrep openvpn` ]
then
    echo "vpn attiva"
else
    echo "vpn non attiva"
    sudo service openvpn start
fi

while [ -z `/sbin/ifconfig | grep tun0 | awk '{print $1}'` ]
do
    echo "aspetto vpn"
    sleep 1s
done

BIND_ADDR="`/sbin/ifconfig tun0 | awk '$1 == \"inet\" {print $2}' | awk -F: '{print $2}'`"
echo "Lego transmission all'IP $BIND_ADDR"
/usr/local/bin/transmission-daemon --bind-address-ipv4 $BIND_ADDR -x $PID

while [ -z "`ss -l | grep 19091`" ]
do
    echo "aspetto rpc transmission"
    sleep 1s
done
python /home/pi/scripts/toggle_torrent.py start

date
echo ""

exit 0
