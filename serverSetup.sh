#! /bin/bash
#
#Description: Copy that is sent to the three other severs from ticket.sh from the main work server.
#Takes the strTicketID parameter sent through ticket.sh into this file searches through the URL to
#assess which ticketID goes with the certain json objects from that URL. Then, the information will be
#printed onto a log file with the ticketID, start date/time, requestor, external IP, hostname, standard
#configuration, software packages, additional configurations, version checks, ticket closing, and
#date of completion. The information will be stored on either web, file, or database server depending on
#the IP address and ticketID sent through the parameters.
#
#Author: Tyce Webster
#
#Creation Date: 04/22/2024
#

#Parameters sent from the ticket.sh
strIP=$1
strTicketID=$2

#Automatically installs jq onto the server the file is being copied to
eval $(sudo apt-get update)
eval $(sudo apt-get install -y jq)

#Creates configurationLogs directory in the server and automatically moves into directory
mkdir configurationLogs
cd configurationLogs/

#Sets first URL to strBaseURL
strBaseURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"
#Debug statement to verify that the URL was saved to the variable
#echo ${strBaseURL}

#Curls the URL to arrResults and parses the information to jq
arrResults=$(curl ${strBaseURL} | jq)
#Debug statement to verify results
#echo ${arrResults}

#Setting up variables for looping through the array of the arrResults
intCurrent=0
#Capturing the length/count of objects in the arrResults
intLength=$(echo ${arrResults} | jq 'length')
#Debug statement to verify the length is correct
#echo ${intLength}

#While loop that goes through the number of items in arrResults and ends it once intCurrent matches
#intLength
while [ $intCurrent -lt $intLength ];
do
#Establishes the current ticketID for the iteration the loop is on to later be verified with the parameter
#strTicketID
strCurrTicketID=$(echo ${arrResults} | jq -r .[${intCurrent}].ticketID)
#Debug statement to verify results
#echo ${strCurrTicketID}

#Checks if strCurrTicketID matches strTicketID for that iteration throught the loop
#so when it does match, it will print the results of the data associated with that ticketID
if [ ${strCurrTicketID} == ${strTicketID} ]; then
#Establishes variables for hostname, requestor, submissionDate, and standardConfig
hostname=$(hostname)
strRequestor=$(echo ${arrResults} | jq -r .[${intCurrent}].requestor)
strSubmissionDate=$(echo ${arrResults} | jq -r .[${intCurrent}].submissionDate)
strStandardConfig=$(echo ${arrResults} | jq -r .[${intCurrent}].standardConfig)
#Debug statement to verify results of variables
#echo ${strRequestor}
#echo ${strSubmissionDate}
#echo ${strStandardConfig}

#Prints the ticketID, start date/time, requestory, external IP, hostname, and standard config
#onto a log file with the strTicketID as its name
echo "TicketID: ${strTicketID}" >> ${strTicketID}.log
echo "Start DateTime: ${strSubmissionDate} $(date +"%H:%M")" >> ${strTicketID}.log
echo "Requestor: ${strRequestor}" >> ${strTicketID}.log
echo "External IP Address: ${strIP}" >> ${strTicketID}.log
echo "Hostname: ${hostname}" >> ${strTicketID}.log
echo "Standard Configuration: ${strStandardConfig}" >> ${strTicketID}.log
echo "" >> ${strTicketID}.log

#Parses the softwarePackages using jq and storing the date into strSoftwarePack
strSoftwarePack=$(echo ${arrResults} | jq -r .[${intCurrent}].softwarePackages)
#Debug statement to verify results
#echo ${strSoftwarePack}

#Sets up software packages for looping by capturing the length of the strSoftwarePack
intCurrSP=0
#Captures length in strSoftwarePack array
intSoftwarePackLN=$(echo ${strSoftwarePack} | jq 'length')
#Debug statement to verify results
#echo ${intSoftwarePackLN}

#If statement checks if the amount of items in intSoftwarePackLN is above 0 which will
#print the items in softwarePackages if it is above zero
if [ ${intSoftwarePackLN} -gt 0 ]; then
#While loop will iterate through the objects in softwarePackages and print the results of them
while [ $intCurrSP -lt $intSoftwarePackLN ];
do
#Establishes the names of the softwarePackages
strSoftwarePackName=$(echo ${strSoftwarePack} | jq -r .[${intCurrSP}].name)
#Debug statement to verify results
#echo ${strSoftwarePackName}

#Prints the names of the softwarePackages and their timestamps to the log file
echo "softwarePackage - ${strSoftwarePackName} - $(date +"%s")" >> ${strTicketID}.log

#Increments intCurrSP to prevent infinite loop
((intCurrSP++))
done
fi

#Parses the additionalConfigs using jq and storing the data in strAdditionalConfig
strAdditionalConfig=$(echo ${arrResults} | jq -r .[${intCurrent}].additionalConfigs)
#Debug statement to verify results
#echo ${strAdditionalConfig}

#Sets up additionalConfigs for looping by capturing the length of the additionalConfigs
intCurrAC=0
#Captures length of strAdditionalConfig array
intAdditionalConfigLN=$(echo ${strAdditionalConfig} | jq 'length')
#Debug statement to verify results
#echo ${strAdditionalConfigLN}

#If statement checks if the amount of items in intAdditionalPackLN is above 0 which will
#print the itmes in additionalConfigs if it is above zero
if [ ${intAdditionalConfigLN} -gt 0 ]; then
#While loop will iterate through the objects in additionalConfigs and print the results of them
while [ $intCurrAC -lt $intAdditionalConfigLN ];
do
#Establishes variable for additionalConfig names
strAdditionalConfigName=$(echo ${strAdditionalConfig} | jq -r .[${intCurrAC}].name)
#Debug statement to verify results
#echo ${strAdditionalConfigName}

#Finds the command configurations for the additional configurations variable
strCommand=$(echo ${strAdditionalConfig} | jq -r .[${intCurrAC}].config)
#Debug statement to verify results
#echo ${strCommand}
#If statement checks if the strCommand has touch as its command then,
#creates strPath sed out the touch and file being created
if [[ $strCommand == *"touch"* ]]; then
strPath=$(echo ${strCommand})
strPath=$(echo $(echo ${strPath}) | sed -e 's/touch//')
strPath=$(echo $(echo ${strPath}) | sed -e 's![^/]*$!!')
#Debug statement to verify results
#echo ${strPath}
#makes new directory based on strPath
eval $(sudo mkdir -p ${strPath})
fi

#Evaluates the command
eval $(sudo ${strCommand})

#Prints the name and timestamp of the additionalConfig to the log file
echo "additionalConfig - ${strAdditionalConfigName} - $(date +"%s")" >> ${strTicketID}.log

#Increments intCurrAC to prevent infinite loop
((intCurrAC++))
done
fi

#If intSoftwarePackLN length is above zero, then it set itself up to install and print the versions of
#softwarePackages
if [ ${intSoftwarePackLN} -gt 0 ]; then
echo "" >> ${strTicketID}.log
#Resets the current length of softwarePackages back to zero
intCurrSP=0

#While loop will iterate through the number of items in software packages and install them and print
#the current versions of them
while [ $intCurrSP -lt $intSoftwarePackLN ];
do
#Establishes the variables for the names and install names
strSoftwarePackName2=$(echo ${strSoftwarePack} | jq -r .[${intCurrSP}].name)
#Debug statements to verify results
#echo ${strSoftwarePackName2}
strSoftwarePackInstall=$(echo ${strSoftwarePack} | jq -r .[${intCurrSP}].install)
#Debug statement to verigy results
#echo ${strSoftwarePackInstall}

#Installs each package as it iterates through the loop
sudo apt-get install ${strSoftwarePackInstall}

#Establishes variable to show the current version of the softwarePackages and uses grep to find the
#specific version of that pacakage and uses sed to display on the current update number
strCurrVers=$(apt show ${strSoftwarePackInstall} | grep Version | sed 's/Version: //g')
#Debug statement to verify results
#echo ${strCurrVers}

#Prints the version check with the current version number onto the log file
echo "Version Check - ${strSoftwarePackName2} - ${strCurrVers}" >> ${strTicketID}.log

#Increment intCurrSP to prevent infinite loop
((intCurrSP++))
done
fi

echo "" >> ${strTicketID}.log

#Sets URL to strServiceNowURL
strServiceNowURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets/completed.php?TicketID=${strTicketID}"
#Debug statement to verify if the URL was saved correctly
#echo ${strServiceNowURL}

#Curls the URL so it can close the ticket on the file and confirm the ticket is complete
arrServiceNowCurl=$(curl ${strServiceNowURL})
#Prints the results
echo ${arrServiceNowCurl}

#Confirms that the ticket was closed and appends it to the log file
echo "TicketClosed" >> ${strTicketID}.log
echo "" >> ${strTicketID}.log

#Prints the date and time of when the program finished onto the log file
echo "Completed: $(date +"%d-%b-%Y %H:%M")" >> ${strTicketID}.log

fi

#Increments the intCurrent to prevent infinite loop
((intCurrent++))
done

