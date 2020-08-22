#!/bin/sh

set -eu

export GITHUB="true"

THEDATE=`date +%d%m%y%H%M`

# Check what to be back up
echo "Backup type: $type"
if [ "$TYPE" = "db" ]
  then
    FILENAME=mysql-$DB_NAME.$THEDATE.sql.gz
    if [ "$DB_TYPE" = "mysql" ]
      then
        SCRIPT="mysqldump -q -u $DB_USER -p'$DB_USER' $DB_NAME | gzip -9 > $FILENAME"
    fi
fi

# Execute SSH Commands to create backups first
sh -c "/bin/drone-ssh $*" 

# Load the deploy key
mkdir -p ~/.ssh && echo $DEPLOY_KEY > ~/.ssh/deploy_key && chmod 600 ~/.ssh/deploy_key

# Rsync the backup files to container
rsync --remove-source-files -avzhe 'ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no -p 22' --progress $USERNAME@$HOST:./mysql* ./backup/

ls -lha
