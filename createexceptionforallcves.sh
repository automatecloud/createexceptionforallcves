#!/bin/bash

LW_PROFILE=default

usage() { echo "Usage: ./createexceptionforallcves.sh host" 1>&2; exit 1; }

if [ $# -eq 0 ]
  then
    echo "No host argument supplied"
    usage
  else
    HOST=$1
fi

export LW_PROFILE=$LW_PROFILE
echo "Lacework Vulnerability Exception for a single host (v0.4)"
echo "Get the current CVEs for the Host $HOST"
getallvulnerabilities=$(lacework api post api/v2/Vulnerabilities/Hosts/search -d '{ "filters": [ { "field": "severity", "expression": "in", "values": ["Medium", "Critical", "High", "Low", "Info", "Unknown"] }, { "field": "fixInfo.fix_available", "expression": "eq", "value": "1" }, { "field": "evalCtx.hostname", "expression": "eq", "value": "'$HOST'" } ], "returns": [ "vulnId" ] }')
lengthofvulnerabilities=$(echo $getallvulnerabilities | jq 'length')
if [ $lengthofvulnerabilities -eq 0 ]; then echo "Host not found inside the Lacework environment"; exit 1; else echo "Host found inside the Lacework environment"; fi
vulnerabilities=$(echo $getallvulnerabilities | jq -r '.data | map(.vulnId) | unique | @csv')
echo "The following Vulnerabilities have been found:"
echo $vulnerabilities
echo "Check if an Exception Rule already exists..."
vulnerabilityexception=$(lacework api post api/v2/VulnerabilityExceptions/search -d '{ "filters": [ { "field": "exceptionType", "expression": "eq", "value": "Host" }, { "field": "exceptionReason", "expression": "eq", "value": "Fix Pending" }, { "field": "exceptionName", "expression": "eq", "value": "All CVEs for host '$HOST'" } ]  }')
lengthofvulnerabilityexception=$(echo $vulnerabilityexception | jq 'length')
if [ $lengthofvulnerabilityexception -eq 0 ]
then
    echo "No Vulnerability Exception found."
    sleep 5
    echo "Adding a new Vulnerability Exception with the current CVEs for the Host $HOST"
    lacework api post api/v2/VulnerabilityExceptions -d '{ "exceptionName": "All CVEs for host '$HOST'", "exceptionReason": "Fix Pending", "vulnerabilityCriteria": { "cve": [ '$vulnerabilities' ] }, "exceptionType": "Host", "props": { "description": "Added all CVEs as exception for the host '$HOST'" }, "resourceScope": { "hostname": [ "'$HOST'" ] } }'
else
    echo "Found Vulnerability Exception."
    sleep 5
    echo "Updating existing Vulnerability Exception with the current CVEs for the Host $HOST"
    echo "Getting the Vulnerability Exception GUID..."
    vulnexceptguid=$(echo $vulnerabilityexception | jq -r '.data[].exceptionGuid')
    echo "The Vulnerability Exception GUID is $vulnexceptguid"
    echo "Updating..."
    lacework api patch api/v2/VulnerabilityExceptions/$vulnexceptguid -d '{ "vulnerabilityCriteria": { "cve": [ '$vulnerabilities' ] } }'
fi
