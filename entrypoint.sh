#!/bin/sh

set -eu

export GITHUB="true"

THEDATE=`date +%d%m%y%H%M`

printenv

# Check what to be back up
echo "Backup type: $INPUT_TYPE"
if [ "$INPUT_TYPE" = "db" ]
  then
    FILENAME=mysql-$INPUT_DB_NAME.$THEDATE.sql.gz
    if [ "$INPUT_DB_TYPE" = "mysql" ]
      then
        SCRIPT="mysqldump -q -u $INPUT_DB_USER -p'$INPUT_DB_USER' $INPUT_DB_NAME | gzip -9 > $FILENAME"
    fi
fi

# Execute SSH Commands to create backups first
sh -c "/bin/drone-ssh $*" 

# Load the deploy key
mkdir -p ~/.ssh && echo $INPUT_DEPLOY_KEY > ~/.ssh/deploy_key && chmod 600 ~/.ssh/deploy_key

# Rsync the backup files to container
rsync --remove-source-files -avzhe 'ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no -p 22' --progress $INPUT_USERNAME@$INPUT_HOST:./mysql* ./backup/

ls -lha
