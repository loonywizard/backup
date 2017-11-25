#!/bin/bash

backupFolders=$(ls $HOME/*/ | grep -o -E "Backup-[0-9]{4}-[0-9]{2}-[0-9]{2}")

lastBackupFolder=$(echo "$backupFolders" | tail -1)

currentDate=`date +%Y-%m-%d`

lastBackupDate=$(echo "$lastBackupFolder" | grep -o -E "[0-9]{4}-[0-9]{2}-[0-9]{2}")

lastBackupDateInSeconds=$(date -d $lastBackupDate +%s)
currentDateInSeconds=$(date -d $currentDate +%s)

backupFolder=""
newFolderWasCreated=false

if [[ $currentDateInSeconds -gt $lastBackupDateInSeconds+7*24*60*60 ]]; then
  backupFolder="$HOME/Backup-$currentDate"
  mkdir $backupFolder
  newFolderWasCreated=true
else
  backupFolder="$HOME/$lastBackupFolder"
fi

sourceFolder="$HOME/source"

if [ ! -d "$sourceFolder" ]; then
  echo "No source folder, aborting"
  exit
fi

if [ $newFolderWasCreated == true ]; then
  files=$(ls -p "$sourceFolder" | grep -v /)
  for file in $files; do
    cp "$sourceFolder/$file" "$backupFolder/$file"
  done
fi
