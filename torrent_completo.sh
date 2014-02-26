#!/bin/bash
#TR_TORRENT_DIR="/home/pi/hdd2/torrent/completi/serie/thrones/"
#TR_TORRENT_NAME="Game.of.Thrones.S03E02.HDTV.x264-2HD"
#TR_TORRENT_ID=31

#Log file used, warning, if you re-use the log file all previous data will be overwritten each time the script is run.
LOGFILE="/home/pi/.torrent/scans/$TR_TORRENT_NAME.log"

source /home/pi/scripts/config.sh

echo transmission-torrent-complete.sh running on `date` > "$LOGFILE"
echo Directory is "$TR_TORRENT_DIR" >> "$LOGFILE"
echo Torrent Name is "$TR_TORRENT_NAME" >> "$LOGFILE"
echo Torrent ID is "$TR_TORRENT_ID" >> "$LOGFILE"
echo Torrent Hash is "$TR_TORRENT_HASH" >> "$LOGFILE"

# Get a list of files (it will include directory/file or similar to any depth)
#if $AUTHENTICATE
#then
#	FILES=$(/usr/local/bin/transmission-remote $HOST:$PORT --auth=$USERNAME:$PASSWORD -t $TR_TORRENT_ID -f | tail -n +3 | cut -c 35-)
#else
#	FILES=$(/usr/local/bin/transmission-remote -t "$TR_TORRENT_ID" -f | tail -n +3 | cut -c 35-)
#fi

# Go to the download directory (the file list is relative to that point)
#cd "$TR_TORRENT_DIR/"

#Moving the filelist into a temporary file wich we can pass on to clamav, using all file names inline gave too many problems regarding special characters
#TEMPFILE=`mktemp /tmp/transmission-torrent-complete-secureXXXXXXXX`
#echo "$FILES" > $TEMPFILE

#We scan our files and we are verbose about it in case of errors, we grep out the "scanning" lines since only the result is interesting to our logfile
#`clamscan -vf $TEMPFILE | grep -ve Scanning* >> "$LOGFILE"`
#`clamscan -vf $TEMPFILE >> "$LOGFILE"`
#We note the exit value of the scan
#RESULT=$?
RESULT=0
echo "RISULTATO = $RESULT" >> "$LOGFILE"

#Casing our result into : 0/1/2/default
#0 -> no problem found, 1 -> a virus was found, 2 -> errors occurred during the scan, other value -> a serious error occurred
#0 -> we delete our log file, 1&2 -> we warn user about the found issue entire log file gets appended to the mail so he can remove the virus or debug
case $RESULT in
	0)
		if $DELETE_LOG_FILES_ON_OK
		then
			rm "$LOGFILE"
		else
			echo "No Virus found, no issues to report" >> "$LOGFILE"
		fi
        echo "avvio script python" >> "$LOGFILE"
		python $SCRIPT "$TR_TORRENT_NAME" "$TR_TORRENT_DIR" "$TR_TORRENT_ID"
        echo "uscito da script python" >> "$LOGFILE"
        exit 0
		;;
	1)
		echo "Virus Found !! Warning $ADMIN" >> "$LOGFILE"
		URL=$(cat $LOGFILE | pastebincl -p -e 1D -n "$TR_TORRENT_NAME" | grep URL: | cut -c 6-)
        echo "avvio script python" >> "$LOGFILE"
		python $SCRIPT "VIRUS" "$URL" "$TR_TORRENT_NAME" "$TR_TORRENT_DIR" "$TR_TORRENT_ID"
        echo "uscito da script python" >> "$LOGFILE"
		exit 1
		;;
	2)
		echo "Error Occurred!! Warning $ADMIN" >> "$LOGFILE"
		URL=$(cat $LOGFILE | pastebincl -p -e 1D -n "$TR_TORRENT_NAME" | grep URL: | cut -c 6-)
        echo "avvio script python" >> "$LOGFILE"
		python $SCRIPT "ERROR" "$URL" "$TR_TORRENT_NAME" "$TR_TORRENT_DIR" "$TR_TORRENT_ID"
        echo "uscito da script python" >> "$LOGFILE"
		exit 1
		;;
	*)
		echo "Return value of scanning was not 0,1 or 2, result was, $RESULT , unknown problematic situation" >> "$LOGFILE"
		URL=$(cat $LOGFILE | pastebincl -p -e 1D -n "$TR_TORRENT_NAME" | grep URL: | cut -c 6-)
        echo "avvio script python" >> "$LOGFILE"
		python $SCRIPT "UNKNOWN" "$URL" "$TR_TORRENT_NAME" "$TR_TORRENT_DIR" "$TR_TORRENT_ID"
        echo "uscito da script python" >> "$LOGFILE"
		exit 1
		;;
esac

exit 0
