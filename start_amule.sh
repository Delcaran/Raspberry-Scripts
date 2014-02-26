#!/bin/bash
date
source /home/pi/scripts/config.sh
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

sudo service amule-daemon start

exit 0
