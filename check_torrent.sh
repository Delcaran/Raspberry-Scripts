#!/bin/bash
source /home/pi/scripts/config.sh
MESSAGE=""
function check_status {
    INSTANCES=$(pgrep transmission | wc -l)
    if [ "$INSTANCES" -gt "0" ]
    then
        VPN=$(/sbin/ifconfig | grep tun0 | awk '{print $1}')
        if [ -z "$VPN" ]
        then
            MESSAGE="Niente VPN: riavvio"
            return 1
        else
            SOCKET=$(/bin/ss -l | grep 57116 | awk '{print $4}')
            ADDR=${SOCKET%":57116"}
            BIND_ADDR="`/sbin/ifconfig tun0 | awk '$1 == \"inet\" {print $2}' | awk -F: '{print $2}'`"
            echo $SOCKET
            echo $ADDR
            echo $BIND_ADDR
            case $ADDR in
                "127.0.0.1") # loopback
                    return 0
                    ;;
                $BIND_ADDR) # collegato alla VPN
                    return 4
                    ;;
                *) # Non collegato
                    MESSAGE="Transmission scollegato: riavvio"
                    return 2
                    ;;
            esac
        fi
    else
        MESSAGE="Transmission spento: riavvio"
        return 3
    fi
}

if [ ! -d "/home/pi/hdd2/torrent/" ]; then
    exit 0
fi
if [ ! -d "/home/pi/hdd1/Film/" ]; then
    exit 0
fi

KEEPALIVE=0
if [ -f $FORCE_TORRENT_FILE ]
then
    KEEPALIVE=1
    echo "keepalive"
else
    KEEPALIVE=0
    echo "not keepalive"
fi

H=$(date +%H)
if (( 1 <= 10#$H && 10#$H < 8 ))
then
    SHOULD_ACTIVE=1
    echo "should active"
else
    SHOULD_ACTIVE=0
    echo "should not active"
fi
check_status
RESTART_NEEDED=$?

case $SHOULD_ACTIVE in
    0) # acceso senza VPN
        case $KEEPALIVE in
            0) # non forzo la connesione
                case $RESTART_NEEDED in
                    0) # loopback ma VPN attiva
                        echo "stop vpn"
                        sudo service openvpn stop #&> /dev/null
                        exit 0 ;;
                    [1-2]) # loopback/no vpn
                        echo "offline, nothing to do"
                        exit 0 ;;
                    *) # spento / collegato: lo avvio fermato
                        echo "Fermo e scollego"
                        $STOP_SCRIPT #&> /dev/null
                        ;;
                esac ;;
            1) # forzo la connessione
                case $RESTART_NEEDED in
                    4) # collegato
                        echo "online, nothing to do"
                        exit 0 ;;
                    *) # non funzionante: lo avvio collegato
                        echo "KEPTALIVE: $MESSAGE"
                        $START_SCRIPT #&> /dev/null
                        ;;
                esac ;;
        esac ;;
    1) # acceso con VPN
        case $RESTART_NEEDED in
            4) # collegato
                echo "online, nothing to do"
                exit 0 ;;
            *) # non funzionante: lo avvio collegato
                echo $MESSAGE
                $START_SCRIPT #&> /dev/null
                ;;
        esac ;;
esac

exit 0
