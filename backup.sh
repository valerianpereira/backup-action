#!/bin/sh -l

set -eu

# Required for appleboy/ssh-action
export GITHUB="true"

THEDATE=`date +%d%m%y%H%M`
BACKUP_DIR="backups"

# Check what to be back up
echo "🗃️Backup type: $INPUT_TYPE"
if [ "$INPUT_TYPE" = "db" ]
  then
    echo "DB type: $INPUT_DB_TYPE"
    if [ "$INPUT_DB_TYPE" = "mysql" ]
      then
        FILENAME=$INPUT_DB_TYPE-$INPUT_DB_NAME.$THEDATE.sql.gz
        INPUT_DB_PORT="${INPUT_DB_PORT:-3306}"
        INPUT_SCRIPT="mysqldump -q -u $INPUT_DB_USER -P $INPUT_DB_PORT -p'$INPUT_DB_PASS' $INPUT_DB_NAME | gzip -9 > $FILENAME"
    fi

    if [ "$INPUT_DB_TYPE" = "mongo" ]
      then
        FILENAME=$INPUT_DB_TYPE-$INPUT_DB_NAME.$THEDATE.gz
        INPUT_DB_PORT="${INPUT_DB_PORT:-27017}"
        INPUT_AUTH_DB="${INPUT_AUTH_DB:-admin}"
        INPUT_SCRIPT="mongodump --port=$INPUT_DB_PORT -d $INPUT_DB_NAME -u $INPUT_DB_USER -p='$INPUT_DB_PASS' --authenticationDatabase=$INPUT_AUTH_DB --gzip -o backmon && tar -cvzf $FILENAME backmon/$INPUT_DB_NAME"
    fi

    if [ "$INPUT_DB_TYPE" = "postgres" ]
      then
        FILENAME=$INPUT_DB_TYPE-$INPUT_DB_NAME.$THEDATE.pgsql.gz
        INPUT_DB_HOST="${INPUT_DB_HOST:-localhost}"
        INPUT_DB_PORT="${INPUT_DB_PORT:-5432}"
        INPUT_EXTRA_ARGS="${INPUT_EXTRA_ARGS:--C --column-inserts}"
        INPUT_SCRIPT="PGPASSWORD='$INPUT_DB_PASS' pg_dump -U $INPUT_DB_USER -h $INPUT_DB_HOST $INPUT_EXTRA_ARGS $INPUT_DB_NAME | gzip -9 > $FILENAME"
    fi
fi

if [ "$INPUT_TYPE" = "directory" ]
  then
    SLUG=$(echo $INPUT_DIRPATH | sed -r 's/[~\^]+//g' | sed -r 's/[^a-zA-Z0-9]+/-/g' | sed -r 's/^-+\|-+$//g' | tr A-Z a-z)
    FILENAME=$INPUT_TYPE-$SLUG.$THEDATE.tar.gz
    INPUT_SCRIPT="tar -cvzf $INPUT_DIRPATH $FILENAME"
    INPUT_DB_TYPE="directory" # Hack!! to survive from writing extra lines of code
fi

# Execute SSH Commands to create backups first
echo "🏃‍♂️Running commands over ssh..."
sh -c "/bin/drone-ssh $*"

# Load the deploy key
echo "🔑Loading the deploy key..."
mkdir -p $HOME/.ssh
echo "$INPUT_DEPLOY_KEY" > $HOME/.ssh/deploykey 
chmod 600 $HOME/.ssh/deploykey
echo "Done!! 🍻"

#-----------------------------
# CREATE DESTINATION DIR IF NOT EXISTS
#-----------------------------
if [ ! -d ./$BACKUP_DIR/ ]
  then
    mkdir $BACKUP_DIR
fi

# Rsync the backup files to container
echo "🔄Sync the $INPUT_DB_TYPE backups... 🗄"
sh -c "rsync --remove-source-files -avzhe 'ssh -i $HOME/.ssh/deploykey -o StrictHostKeyChecking=no' --progress $INPUT_USERNAME@$INPUT_HOST:./$INPUT_DB_TYPE* ./$BACKUP_DIR/"

echo "🔍Show me backups..."
ls -l ./$BACKUP_DIR/

