#!/bin/sh
#POSIX COMPLIANT

BACKUP_FOLDER="/backups"
LOG_FILE_NAME="backup.log"

SCRIPTPATH=$(dirname "$(readlink -f "$0")")

log(){
    printf "%s\t[INFO] %s \n"  "$(date '+%Y/%m/%d %H:%M:%S')" "$1" >> $BACKUP_FOLDER/$LOG_FILE_NAME
}

log_error(){
    printf "%s\t[ERROR] %s \n"  "$(date '+%Y/%m/%d %H:%M:%S')" "$1" >> $BACKUP_FOLDER/$LOG_FILE_NAME
}

print_menu(){
    clear

    echo "ASO 2021-2022"
    echo "Alberto Zugazagoitia Rodríguez"
    echo
    echo "Backup tool for directories"
    echo "---------------------------"
    echo
    echo "Menu"
    echo "    1) Perform a backup"
    echo "    2) Program a backup with cron"
    echo "    3) Restore the content of a backup"
    echo "    4) Exit"
    echo
    printf "Option: "
}

perform_backup(){

    echo "Menu 1"
    printf "Path of the directory: "
    read -r DIRECTORY
    echo
    if [ ! -d "$DIRECTORY" ]; 
    then
        echo "Invalid directory: $DIRECTORY"
        log_error "Invalid directory: $DIRECTORY"
        sleep 3
    fi

    #File name acording to the date
    FILENAME="$(basename "$DIRECTORY")-$(date '+%y%m%d-%H%M').tgz"
    
    #Keep only the directory structure from the given base directory
    tar -czf "$BACKUP_FOLDER/$FILENAME" -C "$DIRECTORY/.." "$(basename "$DIRECTORY")"
  
    FILESIZE=$(stat -c%s "$BACKUP_FOLDER/$FILENAME")

    echo
    log "Backup of $DIRECTORY done"
    echo "Backup of $DIRECTORY done"
    log "The file generated is $FILENAME and ocupies <$FILESIZE> bytes."
    echo "The file generated is $FILENAME and ocupies <$FILESIZE> bytes."
    sleep 4
}

restore_backup(){
    echo "Menu 3"
    echo "The list of existing backups is:"
    #Print all backups mathching the pattern
    find $BACKUP_FOLDER -maxdepth 1 -regex '.*-[0-9]+-[0-9]+\.tgz' -exec basename {}   \;
    echo
    printf "Enter the name of the backup to restore: "

    read -r FILENAME
    if [ ! -f "$BACKUP_FOLDER/$FILENAME" ]; 
    then
        echo "Invalid file: $FILENAME"
        log_error "Invalid file: $FILENAME"
        sleep 3
    fi

    tar -xf "$BACKUP_FOLDER/$FILENAME" 
    log "Restore of $FILENAME done"
    echo
    echo "Restore of $FILENAME done"
    sleep 3
}

cron_backup(){
    echo "Menu 2"
    printf "Absolute path of the directory: "
    read -r DIRECTORY
    echo
    if [ ! -d "$DIRECTORY" ] || [ "$DIRECTORY" = "${DIRECTORY#/}" ] ; 
    then
        echo "Invalid directory: $DIRECTORY"
        log_error "Invalid directory: $DIRECTORY"
        sleep 3
        return    
    fi

    printf "Hour for the backup (0:00-23:59): "
    read -r HOUR 
    echo
    #Check if the hour matches a HH:MM format
    VALID=false
    (echo "$HOUR" | grep -Eq  "^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$")  && VALID=true || VALID=false   
    if [ $VALID = false ] ;
    then
        echo "Invalid hour: $HOUR"
        log_error "Invalid hour: $HOUR"
        sleep 3
        return
    fi

    printf "The backup will execute at %s. Do you agree? (y/n) " "$HOUR"
    read -r AGREE
    echo
    if [ "$AGREE" != "y" ] ;
    then
        echo "Aborted"
        log_error "Aborted"
        sleep 3
        return
    fi

    #Create the cron job
    cp "$SCRIPTPATH/backup-cron.sh" "$BACKUP_FOLDER/backup-cron.sh"
    chmod +x "$BACKUP_FOLDER/backup-cron.sh"
    (crontab -l 2>/dev/null; echo "$(date '+%M %H' -d "$HOUR") * * * $BACKUP_FOLDER/backup-cron.sh $DIRECTORY") | crontab -
    log "Backup of $DIRECTORY scheduled at $HOUR"

    echo
    echo "Backup of $DIRECTORY scheduled at $HOUR"
    sleep 4
}  
switch_option(){
        case $1 in 
            1) 
                perform_backup
                ;;
            2)
                cron_backup
                ;;
            3)
                restore_backup
                ;;
            4)
                exit 0
                ;;
            *)
                echo
                echo "Unknown option: \"$1\""
                sleep 3 
                ;;
        esac        
}

mkdir -p "$BACKUP_FOLDER"

print_menu
read -r OPTION
echo

while [ "$OPTION" -ne 4 ]
do
    switch_option "$OPTION"
    print_menu
    read -r OPTION
    echo
done