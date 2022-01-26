#/bin/bash

DATE=`eval date +%Y%m%d`
DIR=/home/pi/hdd2/backups/
BKP_MYSQL_FILE=mysql_${DATE}.sql
BKP_MYSQL=${DIR}${BKP_MYSQL_FILE}
TAR_BKP=${BKP_MYSQL%.*}.tgz
mysqldump -ubackupper -pbackupper_password --opt --all-databases > $BKP_MYSQL
if [ -f ${TAR_BKP} ]
then
    rm ${TAR_BKP}
fi
cd ${DIR}
tar -zcf ${TAR_BKP} ${BKP_MYSQL_FILE}
rm ${BKP_MYSQL_FILE}
COUNT=0
for file in `eval ls -r mysql_*.tgz`
do
    if [ $COUNT -gt 10 ]
    then
        rm $file
    fi
    ((COUNT++))
done
exit 0
