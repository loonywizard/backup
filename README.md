# backup
This is a backup / upback scripts for unix, that I made at university

### Task
* backup script checks, if there's a backup folder, that was made in less that 7 days.
If there's no backups, created in last 7 days, script should create new backup folder Backup-YYYY-MM-DD,
where YYYY-MM-DD is date of script execution

* If new directory was created, scripts copies all files from ~/source/ folder to just created directory.
If new directory wasn't created, script should copy files with following rules: 
If file is new (there's no file with that filename in current backup directory), just copy it.
If file is already exist in current backup directory, check sizes of both files, if they are different,
rename old file to filename.YYYY-MM-DD, where YYYY-MM-DD - date of script execution, then copy new file

* upback script copies all files from last created backup directory except files with suffix .YYYY-MM-DD
~/restore/ directory 

## Usage
<b>Make sure you have ~/source folder and you don't have ~/restore folder, script can overwrite your files</b>

to backup your ~/source folder use
```bash
./backup.sh
```

to upback last backup to ~/restore folder use
```bash
./upback.sh
```
