#!/bin/sh -l

set -eu

# Required for appleboy/ssh-action
export GITHUB="true"

THEDATE=`date +%d%m%y%H%M`
BACKUP_DIR=`backups`

# Check what to be back up
echo "Backup type: $INPUT_TYPE"
if [ "$INPUT_TYPE" = "db" ]
  then
    echo "DB type: $INPUT_DB_TYPE"
    if [ "$INPUT_DB_TYPE" = "mysql" ]
      then
        FILENAME=mysql-$INPUT_DB_NAME.$THEDATE.sql.gz
        INPUT_DB_PORT="${INPUT_DB_PORT:-3306}"
        INPUT_SCRIPT="mysqldump -q -u $INPUT_DB_USER -P $INPUT_DB_PORT -p'$INPUT_DB_PASS' $INPUT_DB_NAME | gzip -9 > $FILENAME"
    fi

    if [ "$INPUT_DB_TYPE" = "mongo" ]
      then
        FILENAME=mongo-$INPUT_DB_NAME.$THEDATE.gz
        INPUT_DB_PORT="${INPUT_DB_PORT:-27017}"
        INPUT_AUTH_DB="${INPUT_AUTH_DB:-admin}"
        INPUT_SCRIPT="mongodump --port=$INPUT_DB_PORT -d $INPUT_DB_NAME -u $INPUT_DB_USER -p='$INPUT_DB_PASS' --authenticationDatabase=$INPUT_AUTH_DB --gzip -o backmon && tar -cvzf $FILENAME backmon/$INPUT_DB_NAME"
    fi
fi

# Execute SSH Commands to create backups first
echo "Running commands over ssh..."
sh -c "/bin/drone-ssh $*"

# Load the deploy key
echo "Loading the deploy key..."
mkdir -p $HOME/.ssh
echo "$INPUT_DEPLOY_KEY" > $HOME/.ssh/deploykey 
chmod 600 $HOME/.ssh/deploykey
ls -l $HOME/.ssh
echo "Done!!"

#-----------------------------
# CREATE DESTINATION DIR IF NOT EXISTS
#-----------------------------
if [ ! -d ./$BACKUP_DIR/ ]
  then
    mkdir $BACKUP_DIR
fi

echo "Show me destination dir.."
ls -la

# Rsync the backup files to container
echo "Sync the $INPUT_DB_TYPE backups..."
if [ "$INPUT_DB_TYPE" = "mysql" ]
  then
    sh -c "rsync --remove-source-files -avzhe 'ssh -i $HOME/.ssh/deploykey -o StrictHostKeyChecking=no' --progress $INPUT_USERNAME@$INPUT_HOST:./mysql* ./$BACKUP_DIR/"
fi

if [ "$INPUT_DB_TYPE" = "mongo" ]
  then
    sh -c "rsync --remove-source-files -avzhe 'ssh -i $HOME/.ssh/deploykey -o StrictHostKeyChecking=no' --progress $INPUT_USERNAME@$INPUT_HOST:./mongo* ./$BACKUP_DIR/"
fi


echo "Show me backups..."
ls -la && ls -l ./$BACKUP_DIR/

