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
echo "TicketID: ${strTicketID}" >> ${strTicketID}.log
echo "Start DateTime: ${strSubmissionDate}" >> ${strTicketID}.log
echo "Requestor: ${strRequestor}" >> ${strTicketID}.log
echo "External IP Address: ${strIP}" >> ${strTicketID}.log
echo "Hostname: ${hostname}" >> ${strTicketID}.log
echo "Standard Configuration: ${strStandardConfig}" >> ${strTicketID}.log
echo "" >> ${strTicketID}.log

strSoftwarePack=$(echo ${arrResults} | jq -r .[${intCurrent}].softwarePackages)
#echo ${strSoftwarePack}
intCurrSP=0
intSoftwarePackLN=$(echo ${strSoftwarePack} | jq 'length')
#echo ${intSoftwarePackLN}

if [ ${intSoftwarePackLN} -gt 0 ]; then
while [ $intCurrSP -lt $intSoftwarePackLN ];
do
strSoftwarePackName=$(echo ${strSoftwarePack} | jq -r .[${intCurrSP}].name)
#echo ${strSoftwarePackName}
echo "softwarePackage - ${strSoftwarePackName}" >> ${strTicketID}.log

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
#echo ${strAdditionalConfigName}
echo "additionalConfig - ${strAdditionalConfigName}" >> ${strTicketID}.log

((intCurrAC++))
done
fi

if [ ${intSoftwarePackLN} -gt 0 ]; then
echo "" >> ${strTicketID}.log
intCurrSP=0
while [ $intCurrSP -lt $intSoftwarePackLN ];
do
strSoftwarePackName2=$(echo ${strSoftwarePack} | jq -r .[${intCurrSP}].name)
#echo ${strSoftwarePackName2}
strSoftwarePackInstall=$(echo ${strSoftwarePack} | jq -r .[${intCurrSP}].install)
#echo ${strSoftwarePackInstall}
sudo apt-get install ${strSoftwarePackInstall}
strCurrVers=$(${strSoftwarePackInstall} --version)
echo "Version Check - ${strSoftwarePackName2} - ${strCurrVers}" >> ${strTicketID}.log

((intCurrSP++))
done
fi

echo "" >> ${strTicketID}.log

strServiceNowURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets/completed.php?TicketID=${strTicketID}"
#echo ${strServiceNowURL}
arrServiceNowCurl=$(curl ${strServiceNowURL})
echo ${arrServiceNowCurl}

echo "TicketClosed" >> ${strTicketID}.log
echo "" >> ${strTicketID}.log
echo "Completed: $(date +"%d-%b-%Y %H:%M")" >> ${strTicketID}.log

((intCurrent++))
done
