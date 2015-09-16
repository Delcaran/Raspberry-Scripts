#!/bin/bash
TITLE="$1"

source /home/pi/scripts/config.sh

#python ${SCRIPT_AVVIATO} "${TITLE}"

append_email_notification "START: $TITLE"

#send_email_notification

exit $?
