#!/bin/bash
#
#	Project: Restore script
# Gnu/Linux Distro: Tested and working on Void and debian
# Packages needed: rsync and openssh
#	Architecture: Tested and working on aarch64 and x86-64

# Config
IP="10.0.0.10"           #EXAMPLE - Remote host IP
DIRECTORY='backup'      #EXAMPLE - Backup directory
REST_DIR='restored'     #Example - Restore backup directory
TIMESTAMP=$(date "+%Y-%m-%d-%H:%M:%S")
REMOTEUSER=mumriken     #EXAMPLE - Remote user
LOCALUSER=mrm           #EXAMPLE - Local user

# Maximum number to try (Ping the remote server)
((count = 10))

while [[ $count -ne 0 ]] ; do
    ping -c 1 $IP 2>/dev/null 1>/dev/null	# Try once.
    rt=$?
    if [[ $rt -eq 0 ]] ; then
        break		                      	# If okay, exit the loop with "rt"
    fi
    ((count = count - 1))                  	# Count 1 so we don't go on forever
done

if [[ $rt -eq 0 ]] ; then                  	# Final check
    echo "Connection established.";

else
    echo "Connection failed."; 
	exit 68
fi  
	
# Check if there are any available backups on the remove server
AVAILABLE_BACKUPS=$(ssh -p 1027 -i /home/mrm/.ssh/my-servers $REMOTEUSER@$IP "ls $DIRECTORY")
select BACKUP in $AVAILABLE_BACKUPS
do
    rsync -avEPhze "ssh -p 1027 -i /home/mrm/.ssh/backup-servers" $REMOTEUSER@$IP:/home/$REMOTEUSER/$DIRECTORY/$BACKUP /home/$LOCALUSER/$DIRECTORY/restored/
    break
done
