#!/bin/sh
#POSIX COMPLIANT

BACKUP_FOLDER="/backups"
LOG_FILE_NAME="backup.log"

log(){
    printf "%s\t[INFO] [CRON] %s \n"  "$(date '+%Y/%m/%d %H:%M:%S')" "$1" >> $BACKUP_FOLDER/$LOG_FILE_NAME
}

log_error(){
    printf "%s\t[ERROR] [CRON] %s \n"  "$(date '+%Y/%m/%d %H:%M:%S')" "$1" >> $BACKUP_FOLDER/$LOG_FILE_NAME
}



DIRECTORY=$1
if [ ! -d "$DIRECTORY" ]; 
then
    log_error "Invalid directory: $DIRECTORY"
    exit 1 
fi

FILENAME="$(basename "$DIRECTORY")-$(date '+%y%m%d-%H%M').tgz"

    tar -czf "$BACKUP_FOLDER/$FILENAME" -C "$DIRECTORY/.." "$(basename "$DIRECTORY")"

FILESIZE=$(stat -c%s "$BACKUP_FOLDER/$FILENAME")

log "Backup of $DIRECTORY done"

log "The file generated is $FILENAME and ocupies <$FILESIZE> bytes."