
#!/bin/bash

backup_dir="/home/debian"
upload_dir="/tmp/backup"

rsync -a --checksum --delete $backup_dir $upload_dir 2>> /var/log/backup.log
if [ $? -eq 0 ]; then
    echo "$(date "+%F, %T") Buckup create complete" >> /var/log/backup.log
else
    echo "$(date "+%F, %T") Buckup ERROR" >> /var/log/backup.log
fi
