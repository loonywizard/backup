#!/bin/bash

backupFolders=$(ls $HOME/*/ | grep -o -E "Backup-[0-9]{4}-[0-9]{2}-[0-9]{2}")

lastBackupFolder="$HOME/$(echo "$backupFolders" | tail -1)"

if [ ! -d "$lastBackupFolder" ]; then
  echo "No backup folders, aborting"
  exit
fi

cd "$lastBackupFolder"

files=$(find . -type f | grep -E -v ".[0-9]{4}-[0-9]{2}-[0-9]{2}")

restoreFolder="$HOME/restore/"

if [ ! -d "$restoreFolder" ]; then
  mkdir "$restoreFolder"
fi

echo "$files" | while read f; do
  if [ -d "$restoreFolder/$f" ]; then
    echo "Overwriting directory $restoreFolder$f with file $f"
    rm -rf "$restoreFolder/$f"
  fi
  cp --parents "$f" "$restoreFolder/"
done
