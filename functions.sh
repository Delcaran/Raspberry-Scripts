#!/bin/sh
# file di configurazione per script bash

function kill_transmission 
{
    INSTANCES=$(pgrep transmission | wc -l)
    while [ "$INSTANCES" -gt "0" ]
    do
        /usr/local/bin/transmission-remote $HOST:$PORT -n $USERNAME:$PASSWORD --exit > /dev/null
        sleep 1s
        INSTANCES=$(pgrep transmission | wc -l)
    done
    return 0
}

function send_email_notification 
{
    if [ -e ${EMAIL_LOG} ]
    then
        gpg --armor --sign ${GPG_UIDS_OPTIONS} \
            --output - --encrypt ${EMAIL_LOG} | \
            mutt -s ${NOTIFICATION_SUBJECT} ${NOTIFICATION_ADDRESS}

        if [ $? -eq 0 ]
        then
            rm ${EMAIL_LOG}
        fi
    fi
    return $?
}

function send_ufo_file
{
	if [ -e /home/pi/.config/ufo_file ]
	then
		mutt -s "UFO sight in LAN" ${NOTIFICATION_ADDRESS}

		if [ $? -eq 0 ]
		then
			rm /home/pi/.config/ufo_file
		fi
	fi
	return $?
}

function append_email_notification
{
    MSG="$1"
    TIMESTAMP=$(date +'%F %T')
    echo "[$TIMESTAMP] $MSG" >> $EMAIL_LOG
    return $?
}
