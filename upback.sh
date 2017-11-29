#!/bin/bash

# All backups are served at $HOME/Backup-YYYY-MM-DD directories
backupFolders=$(ls $HOME/*/ | grep -o -E "Backup-[0-9]{4}-[0-9]{2}-[0-9]{2}")

lastBackupFolder="$HOME/$(echo "$backupFolders" | tail -1)"

# check if there's no backup folders
if [ ! -d "$lastBackupFolder" ]; then
  echo "No backup folders, aborting"
  exit
fi

# navigate to last backup folder
cd "$lastBackupFolder"

# select all files, also files in directories, but not directories themselves
files=$(find . -type f | grep -E -v ".[0-9]{4}-[0-9]{2}-[0-9]{2}")

# We should restore all files to ~/restore/ directory
restoreFolder="$HOME/restore/"

# create restore directory if it doesn't exists
if [ ! -d "$restoreFolder" ]; then
  mkdir "$restoreFolder"
fi

echo "$files" | while read f; do

  # if there's a directory with filename, that we a going to copy,
  # we should delete this directory
  if [ -d "$restoreFolder/$f" ]; then
    echo "Overwriting directory $restoreFolder$f with file $f"
    rm -rf "$restoreFolder/$f"
  fi

  cp --parents "$f" "$restoreFolder/"
done
