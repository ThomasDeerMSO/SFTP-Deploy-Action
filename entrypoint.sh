#!/bin/sh -l

#set -e at the top of your script will make the script exit with an error whenever an error occurs (and is not explicitly handled)
set -eu

TEMP_SSH_PRIVATE_KEY_FILE='../private_key.pem'

# make sure remote path is not empty
if [ -z "$6" ]; then
   echo 'remote_path is empty'
   exit 1
fi

# use password
if [ -n "${10}" ]; then
	echo 'use sshpass'
	apk add sshpass

	if test $9 == "true"; then
  		echo 'Start delete remote files'
		sshpass -p "${10}" ssh -o StrictHostKeyChecking=no -p "$3" "$1@$2" rm -rf "$6"
	fi
	if test $7 = "true"; then
  		echo "Connection via sftp protocol only, skip the command to create a directory"
	else
 	 	echo 'Create directory if needed'
 	 	sshpass -p "${10}" ssh -o StrictHostKeyChecking=no -p "$3" "$1@$2" mkdir -p "$6"
	fi

	echo 'Rsync Start'
	rsync -avz --delete -e "ssh -p $3" "$5" "$1@$2:$6"

	echo 'Deploy Success'

	exit 0
fi

# keep string format
printf "%s" "$4" > "$TEMP_SSH_PRIVATE_KEY_FILE"
# avoid Permissions too open
chmod 600 "$TEMP_SSH_PRIVATE_KEY_FILE"

# Install rsync if not already available
if ! command -v rsync >/dev/null 2>&1; then
    echo 'Installing rsync...'
    apk add rsync
fi

# delete remote files if needed
if test $9 == "true"; then
	echo 'Start delete remote files'
	ssh -o StrictHostKeyChecking=no -p "$3" -i "$TEMP_SSH_PRIVATE_KEY_FILE" "$1@$2" rm -rf "$6"
fi

if test $7 = "true"; then
	echo "Connection via sftp protocol only, skip the command to create a directory"
else
	echo 'Create directory if needed'
	ssh -o StrictHostKeyChecking=no -p "$3" -i "$TEMP_SSH_PRIVATE_KEY_FILE" "$1@$2" mkdir -p "$6"
fi

echo 'Rsync Start'
rsync -avz --delete -e "ssh -p $3 -i $TEMP_SSH_PRIVATE_KEY_FILE" "$5" "$1@$2:$6"

echo 'Deploy Success'
exit 0
