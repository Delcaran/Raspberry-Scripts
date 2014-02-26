#!/bin/bash
ACTION="$1"
SERVICE="$2"
SCRIPT="${ACTION}_${SERVICE}.sh"

/home/pi/scripts/${SCRIPT}

exit 0

