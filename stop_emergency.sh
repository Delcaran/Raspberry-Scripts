#!/bin/bash
source /home/pi/scripts/config.sh

sudo mount -a

bash /home/pi/manage.sh check torrent 0
