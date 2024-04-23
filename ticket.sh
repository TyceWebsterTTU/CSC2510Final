#!/bin/bash
# Description: Copies and runs automation script on GCP remote server
# Author: Tyce Webster
# Date: 23 April 2024

strIP=$1
strTicketID=$2
strUsername=$3
cd
eval "$(ssh-agent -s)"

# The location of my gcp ssh key is in the .ssh directory
# My gcp ssh key is called gcpgithubterm
ssh-add .ssh/gcpgithubterm

strTicketURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"
#echo ${strTicketURL}

arrResults=$(curl ${strTicketURL})
#echo ${arrResults}

# Using scp, copies a shell script called serverSetup.sh from the
# current directory to the home directory on the remote server
# Note the two lines below is actually one line
scp -i .ssh/gcpgithubterm serverSetup.sh "${strUsername}"@"${strIP}":/home/"${strUsername}"

ssh ${strUsername}@${strIP} "chmod 755 serverSetup.sh"
ssh ${strUsername}@${strIP} "./serverSetup.sh ${strIP} ${strTicketID}"
