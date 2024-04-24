#! /bin/bash

strIP=$1
strTicketID=$2

mkdir configurationLogs
cd configurationLogs/

strBaseURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"
#echo ${strBaseURL}

arrResults=$(curl ${strBaseURL} | jq)
#echo ${arrResults}

intCurrent=0
intLength=$(echo ${arrResults} | jq 'length')
echo ${intLength}

while [ $intCurrent -lt $intLength ];
do
strRequestor=$(echo ${arrResults} | jq -r .[${intCurrent}].requestor)
strSubmissionDate=$(echo ${arrResults} | jq -r .[${intCurrent}].submissionDate)
strSoftwarePack=$(echo ${arrResults} | jq -r .[${intCurrent}].softwarePackages)
strAdditionalConfig=$(echo ${arrResults} | jq -r .[${intCurrent}].additionalConfigs)
echo ${strRequestor}
echo ${strSubmissionDate}
echo ${strSoftwarePack}
echo ${strAdditionalConfig}
((intCurrent++))
done
