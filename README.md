# SmartBackup

A simple, modular Bash script for creating timestamped backups of any file.  
It skips backups if the file hasn’t changed (MD5 comparison) and automatically prunes older versions, keeping only the most recent N backups.  
Perfect for lightweight file versioning and automated cron-based backups.  

**Usage:** `./backup.sh /path/to/source/file /path/to/destination/dir [max_backups]`
