#!/bin/bash
date

source /home/pi/scripts/config.sh

PIDFILE="/home/pi/.torrent/start.pid"
if [ -e $PIDFILE ]
then
    echo "Another script instance is running."
    exit 1
else
    touch $PIDFILE
    if [ -e $PID ]
    then
        echo -n "Aspetto chiusura Transmission "
        count=$(ps x | grep -ic 'transmission')
        while [[ $count > 1 ]]
        do
            /usr/local/bin/transmission-remote $HOST:$PORT -n $USERNAME:$PASSWORD --exit &>/dev/null
            sleep 1s
            echo -n "."
            count=$(ps x | grep -ic 'transmission')
        done
        echo " OK"
        rm $PID &>/dev/null
    fi

    sudo systemctl start openvpn@airvpn.service
    echo -n "Aspetto VPN "
    while [ -z `/sbin/ifconfig | grep tun0 | awk '{print $1}'` ]
    do
        echo -n "."
        sleep 1s
    done
    echo " OK"

    #PORT=$(cat $PORT_FILE)
    BIND_ADDR="`/sbin/ifconfig tun0 | awk '$1 == \"inet\" {print $2}' | awk -F: '{print $2}'`"
    echo "Lego transmission all'IP ${BIND_ADDR}."
    /usr/local/bin/transmission-daemon --bind-address-ipv4 $BIND_ADDR -x $PID

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
    trap "rm -f $PIDFILE; exit" INT TERM EXIT
    rm -f $PIDFILE
fi
exit 0
