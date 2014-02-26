#!/bin/bash

BACKUP_DIR="/home/pi/hdd1/backups"
CONF_DIR="/home/pi/configs"

# copio nella directory /home/pi/configs tutte le configurazioni non in /home
dpkg --get-selections > $CONF_DIR/packages
cp /etc/fstab $CONF_DIR/fstab
cp /etc/default/openvpn $CONF_DIR/default_openvpn
cp /etc/rc.local $CONF_DIR/rclocal
cp /etc/ssh/sshd_config $CONF_DIR/sshd_config

# creo un archivio tar incrementale nel disco esterno
# Cancella i vecchi archivi presenti
rm $BACKUP_DIR/home-*.tgz
# prepara il nuovo archivio, completo se il file di log
#non esiste, altrimenti incrementale
tar zcvf $BACKUP_DIR/home-`date +%s`.tgz \
    --listed-incremental=/$BACKUP_DIR/home_backup.tarlog \
    --exclude 'hdd?/*' \
    /home/pi
