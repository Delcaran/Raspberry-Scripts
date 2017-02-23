#!/bin/bash
$HOME/manage.sh unforce torrent
sleep 1
$HOME/manage.sh block torrent
sleep 1
$HOME/manage.sh check torrent
exit 0
