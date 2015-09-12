#!/bin/bash
TITLE="$1"

source /home/pi/scripts/config.sh

python ${SCRIPT_AVVIATO} "${TITLE}"

send_email_notification