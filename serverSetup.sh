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
#echo ${strRequestor}
#echo ${strSubmissionDate}
#echo ${strStandardConfig}
echo "TicketID: ${strTicketID}"
echo "Start DateTime: ${strSubmissionDate}"
echo "Requestor: ${strRequestor}"
echo "External IP Address: ${strIP}"
echo "Hostname: ${hostname}"
echo "Standard Configuration: ${strStandardConfig}"
echo ""

strSoftwarePack=$(echo ${arrResults} | jq -r .[${intCurrent}].softwarePackages)
#echo ${strSoftwarePack}
intCurrSP=0
intSoftwarePackLN=$(echo ${strSoftwarePack} | jq 'length')
#echo ${intSoftwarePackLN}

if [ ${intSoftwarePackLN} -gt 0 ]; then
while [ $intCurrSP -lt $intSoftwarePackLN ];
do
strSoftwarePackName=$(echo ${strSoftwarePack} | jq -r .[${intCurrSP}].name)
echo "softwarePackage - ${strSoftwarePackName}"

((intCurrSP++))
done
fi

strAdditionalConfig=$(echo ${arrResults} | jq -r .[${intCurrent}].additionalConfigs)
#echo ${strAdditionalConfig}
intCurrAC=0
intAdditionalConfigLN=$(echo ${strAdditionalConfig} | jq 'length')
#echo ${strAdditionalConfigLN}

if [ ${intAdditionalConfigLN} -gt 0 ]; then
while [ $intCurrAC -lt $intAdditionalConfigLN ];
do
strAdditionalConfigName=$(echo ${strAdditionalConfig} | jq -r .[${intCurrAC}].name)
echo "additionalConfig - ${strAdditionalConfigName}"

((intCurrAC++))
done
fi

echo ""
echo "Version Check - "
echo ""

strServiceNowURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets/completed.php?TicketID=${strTicketID}"
#echo ${strServiceNowURL}
arrServiceNowCurl=$(curl ${strServiceNowURL})
echo ${arrServiceNowCurl}

echo "TicketClosed"
echo ""
echo "Completed: $(date +"%d-%b-%Y %H:%M")"

((intCurrent++))
done
