#!/bin/bash
date
source /home/pi/scripts/config.sh
if [ `pgrep amule` ]
then
    echo "fermo amule"
    sudo service amule-daemon stop && echo "amule fermato"
else
	echo "amule non attivo"
fi

if [ `pgrep openvpn` ]
then
    echo "vpn attiva"
    sudo service openvpn stop
else
    echo "vpn non attiva"
#    sudo service openvpn start
fi
date
exit 0
