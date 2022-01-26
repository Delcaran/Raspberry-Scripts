#!/bin/bash
ACTION="$1"
SERVICE="$2"
#OPTIONS="$3"
SCRIPT="${ACTION}_${SERVICE}.sh"

#/home/pi/scripts/${SCRIPT} ${OPTIONS}
/home/pi/scripts/${SCRIPT}

exit 0

