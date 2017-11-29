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

#files=$(ls -p "$sourceFolder" | grep -v /)

if [ $newFolderWasCreated == true ]; then

  echo "New catalog $backupFolder was created at $currentDate" >> $reportFilename
  
  ls -f "$sourceFolder" | while read f; do
    cp "$sourceFolder/$f" "$backupFolder/$f"
    echo "$f" >> $reportFilename
  done < "$sourceFolder"

else

  echo "New files were added to $backupFolder at $currentDate" >> $reportFilename

  changedFilesInfo=""

  ls -f "$sourceFolder" | while read f; do
    if [ -e "$backupFolder/$f" ]; then
      oldFileSize=$(stat -c%s "$backupFolder/$f")
      newFileSize=$(stat -c%s "$sourceFolder/$f")
      if [ $oldFileSize -ne $newFileSize ]; then
        mv "$backupFolder/$f" "$backupFolder/$f.$currentDate"
        cp "$sourceFolder/$f" "$backupFolder/$f"
        changedFilesInfo=$changedFilesInfo"$f $f.$currentDate "
      fi
    else
      cp "$sourceFolder/$f" "$backupFolder/$f"
      echo "$f" >> $reportFilename
    fi
  done

  echo "$changedFilesInfo" >> $reportFilename

fi
