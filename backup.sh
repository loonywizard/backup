#!/bin/bash

# All backups are served at $HOME/Backup-YYYY-MM-DD directories
# get all backup directories
# grep -o, --onlymatching - print only matched parts of a matching line
# grep -E, --extended-regexp, interpret PATTERN as an extended regular expression
backupFolders=$(ls $HOME/*/ | grep -o -E "Backup-[0-9]{4}-[0-9]{2}-[0-9]{2}")

lastBackupDateInSeconds=0
lastBackupFolder=""

# check if we have backup folders
if [ $backupFolders ]; then

  # get last added backup folder
  # tail -1 reads last item of $backupFolders
  lastBackupFolder=$(echo "$backupFolders" | tail -1)

  # get date of last backup
  lastBackupDate=$(echo "$lastBackupFolder" | grep -o -E "[0-9]{4}-[0-9]{2}-[0-9]{2}")

  # parse last backup date, save result in seconds
  lastBackupDateInSeconds=$(date -d $lastBackupDate +%s)
fi

# get current date in YYYY-MM-DD template and in seconds
currentDate=`date +%Y-%m-%d`
currentDateInSeconds=$(date -d $currentDate +%s)

# We will make the backup to that folder
backupFolder=""
newFolderWasCreated=false

# Check if the last backup was created in less than 7 days
# if it wasn't - create new backup folder
if [[ $currentDateInSeconds -gt $lastBackupDateInSeconds+7*24*60*60 ]]; then
  backupFolder="$HOME/Backup-$currentDate"
  mkdir $backupFolder
  newFolderWasCreated=true
else
  backupFolder="$HOME/$lastBackupFolder"
fi

# This is the folder, from where we're making a back up
sourceFolder="$HOME/source"

# Check, if there's no source folder
if [ ! -d "$sourceFolder" ]; then
  echo "No source folder, aborting"
  exit
fi

# This is report file, which has logs from script
reportFilename="$HOME/backup-report"

# Navigate to folder with data, that need to be saved to backup
cd "$sourceFolder"

# select all files, also files in directories, but not directories themselves
files=$(find . -type f)

# If new backup folder was created:
# - copy all files from source folder to backup folder
# If we use last backup folder:
# - copy all new files
# - if already have file with the same name in the same folder:
#   compare filesizes, if equals - do not copy,
#   if not, rename old file to filename.YYYY-MM-DD and copy new file 
if [ $newFolderWasCreated == true ]; then

  echo "New catalog $backupFolder was created at $currentDate" >> $reportFilename

  echo "$files" | while read filename; do
    
    # cp --parents means, that we copy not just files, but also directory, where 
    # file is located, with --parents flag we need to specify destination as folder,
    # not as folder and filename
    cp --parents "$filename" "$backupFolder/"
    echo "$filename" >> $reportFilename
  done

else

  echo "New files were added to $backupFolder at $currentDate" >> $reportFilename

  changedFilesInfo=""

  echo "$files" | while read filename; do
    
    # check if file already exists in backup folder
    if [ -e "$backupFolder/$filename" ]; then

      # get and compare filesizes
      oldFileSize=$(stat -c%s "$backupFolder/$filename")
      newFileSize=$(stat -c%s "$sourceFolder/$filename")
      
      if [ $oldFileSize -ne $newFileSize ]; then
        
        # mark old file with .YYYY-MM-DD suffix
        mv "$backupFolder/$filename" "$backupFolder/$filename.$currentDate"
        cp "$sourceFolder/$filename" "$backupFolder/$filename"
        
        changedFilesInfo=$changedFilesInfo"$filename $filename.$currentDate "
      fi

    else
      cp --parents "$filename" "$backupFolder/"
      echo "$filename" >> $reportFilename
    fi
  done

  echo "$changedFilesInfo" >> $reportFilename

fi
