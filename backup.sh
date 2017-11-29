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

cd "$sourceFolder"

files=$(find . -type f)

if [ $newFolderWasCreated == true ]; then

  echo "New catalog $backupFolder was created at $currentDate" >> $reportFilename

  echo "$files" | while read f; do
    cp --parents "$f" "$backupFolder/"
    echo "$f" >> $reportFilename
  done

else

  echo "New files were added to $backupFolder at $currentDate" >> $reportFilename

  changedFilesInfo=""

  echo "$files" | while read f; do
    if [ -e "$backupFolder/$f" ]; then
      oldFileSize=$(stat -c%s "$backupFolder/$f")
      newFileSize=$(stat -c%s "$sourceFolder/$f")
      if [ $oldFileSize -ne $newFileSize ]; then
        mv "$backupFolder/$f" "$backupFolder/$f.$currentDate"
        cp "$sourceFolder/$f" "$backupFolder/$f"
        changedFilesInfo=$changedFilesInfo"$f $f.$currentDate "
      fi
    else
      cp --parents "$f" "$backupFolder/"
      echo "$f" >> $reportFilename
    fi
  done

  echo "$changedFilesInfo" >> $reportFilename

fi
