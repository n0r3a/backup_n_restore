#!/bin/bash
#
#   Project: Backup script
#   GNU/Linux Distro: Tested on Void Linux and Debian 
#   Packages needed: rsync and openssh
#   Architecture: Tested and working on x86-64 and aarch64


# Use while loop and ping the backup server.
IP="REMOTE_IP_HERE"                           		# CHANGE THIS

# Maximum number to try
((count = 10))								

while [[ $count -ne 0 ]] ; do
    ping -c 1 $IP 2>&1 >/dev/null			# Try once.
    rt=$?
    if [[ $rt -eq 0 ]] ; then
        break		                      	      	# If okay, break the loop with "rt"
    fi
    ((count = count - 1))                  	  	# Count 1 so we don't go on forever
done

if [[ $rt -eq 0 ]] ; then                 	  	# Final check
    echo "Connection established.";
else
    echo "Connection failed."; 
	exit 68
fi  

# Config
DIRECTORY='backup'      
TIMESTAMP=$(date "+%Y-%m-%d-%H:%M:%S")
REMOTEUSER=USERNAME 					#EXAMPLE
LOCALUSER=LOCAL_USERNAME				#EXAMPLE
SSH="ssh -p 1027 -i /home/mrm/.ssh/backup-servers"


# Create backup directory
mkdir -p "/home/$LOCALUSER/$DIRECTORY/$TIMESTAMP"

# Copy local /etc directory to backup directory
cp -aR /etc "/home/$LOCALUSER/$DIRECTORY/$TIMESTAMP" 2>/dev/null >/dev/null

#Check entries / are there any older backups?
BACKUP_ENTRIES=$(ssh -p 22 -i /home/$LOCALUSER/.ssh/YOUR_SSH_KEY $REMOTEUSER@$IP "ls /home/$REMOTEUSER/$DIRECTORY | wc -l")
if [ $BACKUP_ENTRIES -gt 0 ]
then
    echo "Creating snapshot..."
    LATEST=$(ssh -p 22 -i /home/$LOCALUSER/.ssh/YOUR_SSH_KEY $REMOTEUSER@$IP "ls /home/$REMOTEUSER/$DIRECTORY | tail -1")  # Will check if there are any existing backups
    $SSH $REMOTEUSER@$IP "cp -al /home/$REMOTEUSER/$DIRECTORY/$LATEST /home/$REMOTEUSER/$DIRECTORY/$TIMESTAMP 2>/dev/null >/dev/null"
fi

# Transfer the local backup to main server. rsync will only transfer changed or added files in /etc.
rsync -avEPhze "ssh -p 22 -i /home/$LOCALUSER/.ssh/MY_SSH_KEY" "/home/$LOCALUSER/$DIRECTORY/$TIMESTAMP" "$REMOTEUSER@$IP:/home/$REMOTEUSER/$DIRECTORY/"


# END

exit 0
