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

reportFilename="$HOME/backup-report"

files=$(ls -p "$sourceFolder" | grep -v /)

if [ $newFolderWasCreated == true ]; then

  echo "New catalog $backupFolder was created at $currentDate" >> $reportFilename
  
  for file in $files; do
    cp "$sourceFolder/$file" "$backupFolder/$file"
    echo "$file" >> $reportFilename
  done

else

  for file in $files; do
    if [ -e "$backupFolder/$file" ]; then
      oldFileSize=$(stat -c%s "$backupFolder/$file")
      newFileSize=$(stat -c%s "$sourceFolder/$file")
      if [ $oldFileSize -ne $newFileSize ]; then
        mv "$backupFolder/$file" "$backupFolder/$file.$currentDate"
        cp "$sourceFolder/$file" "$backupFolder/$file"  
      fi
    else
      cp "$sourceFolder/$file" "$backupFolder/$file"
    fi
  done

fi
