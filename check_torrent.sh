#!/bin/bash
source /home/pi/scripts/config.sh
MESSAGE=""

# Abbiamo una connessione attiva su VPN?
function check_status {
    INSTANCES=$(pgrep transmission | wc -l)
    if [ "$INSTANCES" -gt "0" ]
    then
        #echo "Transmission attivo."
        if [ -z `pidof openvpn` ]
        then
            #echo "No VPN"
            MESSAGE="Niente VPN: riavvio."
            return 1
        else
            #echo "Ho VPN"
            SOCKET=$(/bin/ss -l | grep -m 1 26339 | awk '{print $5}')
            ADDR=${SOCKET%":26339"}
            BIND_ADDR="`/sbin/ifconfig tun0 | awk '$1 == \"inet\" {print $2}' | awk -F: '{print $2}'`"
            case $ADDR in
                "127.0.0.1") # loopback
                    #echo ":loopback:"
                    return 0
                    ;;
                $BIND_ADDR) # collegato alla VPN
                    #echo ":on VPN:"
                    return 4
                    ;;
                *) # Non collegato
                    #echo ":unlinked:"
                    MESSAGE="Transmission scollegato: riavvio."
                    return 2
                    ;;
            esac
        fi
    else
        MESSAGE="Transmission spento: riavvio."
        return 3
    fi
}

# Ho accesso ai dischi rigidi?
HDD_DOWN=0
if [ ! -d "/home/pi/hdd2/torrent/" ]; then
    HDD_DOWN=1
fi
if [ ! -d "/home/pi/hdd1/Film/" ]; then
    HDD_DOWN=1
fi
if [ "$HDD_DOWN" -gt "0" ]; then
    if [ ! -f $HDD_DOWN_FILE ]; then
        touch $HDD_DOWN_FILE
        #python /home/pi/scripts/config.py "!!! DISK FAILURE !!!"
        append_email_notification "!!! DISK FAILURE !!!"
        #send_email_notification
        $STOP_SCRIPT
    fi
    exit 1
else
    if [ -f $HDD_DOWN_FILE ]; then
        rm $HDD_DOWN_FILE
    fi
fi

# Durante le fasi di avvio programmato devo mantenere il torrent spento?
BLOCK=0
if [ -f $BLOCK_TORRENT_FILE ]
then
    BLOCK=1
    #echo "block"
else
    BLOCK=0
    #echo "not block"
fi

# Durante le fasi di stop programmato devo mantenere il torrent acceso?
KEEPALIVE=0
if [ -f $FORCE_TORRENT_FILE ]
then
    KEEPALIVE=1
    #echo "keepalive"
else
    KEEPALIVE=0
    #echo "not keepalive"
fi

# Nel momento attuale e' programmato un avvio o uno stop?
D=$(date +%w)
H=$(date +%H)
if (( $SCHEDULER_DAY_START <= 10#$D && 10#$D < $SCHEDULER_DAY_END ))
then # lavoro
    #echo ":weekday:"
    if (( $SCHEDULER_HOUR_WEEK_START <= 10#$H && 10#$H < $SCHEDULER_HOUR_WEEK_END ))
    then
        SHOULD_ACTIVE=1
        #echo ":should active:"
    else
        SHOULD_ACTIVE=0
        #echo ":should not active:"
    fi
else # weekend
    #echo "weekend"
    if (( $SCHEDULER_HOUR_WEEKEND_START <= 10#$H && 10#$H < $SCHEDULER_HOUR_WEEKEND_END ))
    then
        SHOULD_ACTIVE=1
        #echo ":should active:"
    else
        SHOULD_ACTIVE=0
        #echo ":should not active:"
    fi
fi
check_status
RESTART_NEEDED=$?

case $SHOULD_ACTIVE in
    0) # acceso senza VPN
        case $KEEPALIVE in
            0) # non forzo la connesione
                case $RESTART_NEEDED in
                    0) # dovrei andare in loopback ma la VPN e' attiva
                        echo "Stop VPN."
                        sudo systemctl stop openvpn@airvpn.service #&> /dev/null
                        exit 0 ;;
                    [1-2]) # sono in loopback oppure non ho la vpn
                        echo "Offline, nothing to do."
                        exit 0 ;;
                    *) # spento / collegato: lo avvio fermato
                        echo "Fermo e scollego."
                        $STOP_SCRIPT #&> /dev/null
                        ;;
                esac
                ;;
            1) # forzo la connessione
                case $RESTART_NEEDED in
                    4) # collegato
                        echo "Online, nothing to do."
                        exit 0 ;;
                    *) # non funzionante: lo avvio collegato
                        echo "KEPTALIVE: $MESSAGE."
                        $START_SCRIPT #&> /dev/null
                        ;;
                esac
                ;;
        esac
        ;;
    1) # acceso con VPN
		case $BLOCK in
			0)	# non devo bloccare, funzionamento normale
        		case $RESTART_NEEDED in
            		4) # collegato
                		echo "Online, nothing to do."
                		exit 0 ;;
            		*) # non funzionante: lo avvio collegato
                		echo $MESSAGE
                		$START_SCRIPT #&> /dev/null
                		;;
        		esac
        		;;
        	1)  # devo bloccare
				case $RESTART_NEEDED in
					0) # dovrei andare in loopback ma la VPN e' attiva
                        echo "Stop VPN."
                        sudo systemctl stop openvpn@airvpn.service #&> /dev/null
                        exit 0 ;;
                    [1-2]) # sono in loopback oppure non ho la vpn
                        echo "Offline, nothing to do."
                        exit 0 ;;
                    *) # spento / collegato: lo avvio fermato
                        echo "Fermo e scollego."
                        $STOP_SCRIPT #&> /dev/null
                        ;;
                esac
                ;;
        esac
        ;;
esac

exit 0
