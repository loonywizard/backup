#!/bin/bash

backupFolders=$(ls $HOME/*/ | grep -o -E "Backup-[0-9]{4}-[0-9]{2}-[0-9]{2}")

lastBackupFolder="$HOME/$(echo "$backupFolders" | tail -1)"

if [ ! -d "$lastBackupFolder" ]; then
  echo "No backup folders, aborting"
  exit
fi

files=$(ls "$lastBackupFolder" | grep -E -v ".[0-9]{4}-[0-9]{2}-[0-9]{2}")

restoreFolder="$HOME/restore"

if [ ! -d "$restoreFolder" ]; then
  mkdir "$restoreFolder"
fi

echo "$files" | while read f; do
  cp "$lastBackupFolder/$f" "$restoreFolder/$f"
done
