#!/bin/bash
TITLE="$1"

source /home/pi/scripts/config.sh

#python ${SCRIPT_AVVIATO} "${TITLE}"

TIMESTAMP=$(date +'%F %T')
echo "[$TIMESTAMP] START: $TITLE \n" >> $EMAIL_LOG

send_email_notification

exit 0
