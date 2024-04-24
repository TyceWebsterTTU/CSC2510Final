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
#echo ${intLength}

while [ $intCurrent -lt $intLength ];
do
hostname=$(hostname)
strRequestor=$(echo ${arrResults} | jq -r .[${intCurrent}].requestor)
strSubmissionDate=$(echo ${arrResults} | jq -r .[${intCurrent}].submissionDate)
strStandardConfig=$(echo ${arrResults} | jq -r .[${intCurrent}].standardConfig)
strSoftwarePack=$(echo ${arrResults} | jq -r .[${intCurrent}].softwarePackages)
strAdditionalConfig=$(echo ${arrResults} | jq -r .[${intCurrent}].additionalConfigs)
#echo ${strRequestor}
#echo ${strSubmissionDate}
#echo ${strStandardConfig}
#echo ${strSoftwarePack}
#echo ${strAdditionalConfig}

echo "TicketID: ${strTicketID}"
echo "Start DateTime: ${strSubmissionDate}"
echo "Requestor: ${strRequestor}"
echo "External IP Address: ${strIP}"
echo "Hostname: ${hostname}"
echo "Standard Configuration: ${strStandardConfig}"
echo ""
echo "softwarePackage - ${strSoftwarePack}"
echo "addtionalConfig - ${strAddtionalConfig}"
((intCurrent++))
done
