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

#Check if the backup directory exists and is a directory, then test for write permissions
if [ ! -d "$BACKUP_FOLDER" ]; 
then
    if [ ! -w "$BACKUP_FOLDER" ];
    then
        echo "The folder $BACKUP_FOLDER does not exist and you don't have the permission to create it."
        log_error "The folder $BACKUP_FOLDER does not exist and you don't have the permission to create it."
        sleep 3
        exit 1
    fi
fi


#Check if the directory exists and is a directory, then test for read permissions
if [ ! -d "$DIRECTORY" ]; 
then
    log_error "Invalid directory: $DIRECTORY"
    exit 1 
else
    if [ ! -r "$DIRECTORY" ];
    then
        echo "You don't have the permission to write to $DIRECTORY."
        log_error "You don't have the permission to write to $DIRECTORY."
        sleep 3
        return
    fi
fi

FILENAME="$(basename "$DIRECTORY")-$(date '+%y%m%d-%H%M').tgz"

    tar -czf "$BACKUP_FOLDER/$FILENAME" -C "$DIRECTORY/.." "$(basename "$DIRECTORY")"

FILESIZE=$(stat -c%s "$BACKUP_FOLDER/$FILENAME")

log "Backup of $DIRECTORY done"

log "The file generated is $FILENAME and ocupies <$FILESIZE> bytes."