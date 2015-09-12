#/bin/bash

DATE=`eval date +%Y%m%d`
DIR=/home/pi/hdd2/backups/
BKP_HOME_FILE=home_${DATE}
BKP_HOME=${DIR}${BKP_HOME_FILE}
TAR_BKP=${BKP_HOME%.*}.tgz
if [ -f ${TAR_BKP} ]
then
    rm ${TAR_BKP}
fi
cd ${DIR}
tar -zcfpv \
    --exclude hdd? \
    --exclude .aMule \
    --exclude .cache \
    --exclude .bitcoin \
    --exclude .couchpotato \
    --exclude .dbus \
    --exclude .fontconfig \
    --exclude .gvfs \
    --exclude .rssdler \
    --exclude .pyload \
    --exclude .session \
    --exclude .subversion \
    --exclude .xbmc \
    --exclude .bitcoin \
    ${TAR_BKP} /home/pi/

exit 0
