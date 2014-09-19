#!/bin/bash
DATE=`eval date +%Y%m%d`
for DEST in /home/pi/hdd1 /home/pi/hdd2
    do
        DESTDIR="${DEST}/git_backup"
        for REPO in /home/git/dentalab.git
            do
                cd "${REPO}"
                BKP_FILE="${REPO##*/}_${DATE}"
                git bundle create "${DESTDIR}/${BKP_FILE}" --all
#                cd "${DESTDIR}"
#                tar -Jcf "${BKP_FILE}.txz" "${BKP_FILE}"
#                rm ${BKP_FILE}
    done
    COUNT=0
    for file in `eval ls -r $DESTDIR`
    do
        if [ $COUNT -gt 10 ]
        then
            rm $DESTDIR/$file
        fi
        ((COUNT++))
    done
done


