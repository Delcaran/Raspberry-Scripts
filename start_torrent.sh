#!/bin/bash
date

source /home/pi/scripts/config.sh

PIDFILE="/home/pi/.torrent/start.pid"
if [ -e $PIDFILE ]
then
	echo "Another script instance is running..."
	exit 1
else
	touch $PIDFILE
	if [ -e $PID ]
	then
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
	fi
	
	if [ `pgrep openvpn` ]
	then
		echo "vpn attiva"
	else
		echo "vpn non attiva"
		sudo service openvpn start
	fi

	if [ -z `/sbin/ifconfig | grep tun0 | awk '{print $1}'` ]
	then
		echo -ne "Aspetto VPN "
		while [ -z `/sbin/ifconfig | grep tun0 | awk '{print $1}'` ]
		do
			spinning_wait
		done
	fi

	#PORT=$(cat $PORT_FILE)
	BIND_ADDR="`/sbin/ifconfig tun0 | awk '$1 == \"inet\" {print $2}' | awk -F: '{print $2}'`"
	echo "Lego transmission all'IP $BIND_ADDR"
	/usr/local/bin/transmission-daemon --bind-address-ipv4 $BIND_ADDR -x $PID

	if [ -z "`ss -l | grep 19091`" ]
	then
		echo -ne "Aspetto RPC Transmission "
		while [ -z "`ss -l | grep 19091`" ]
		do
			spinning_wait
		done
	fi
	#python /home/pi/scripts/toggle_torrent.py start

	date
	echo ""
	trap "rm -f $PIDFILE; exit" INT TERM EXIT
	rm -f $PIDFILE
fi
exit 0
