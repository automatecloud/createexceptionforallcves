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
echo "Lacework Vulnerability Exception for a single host (v0.1)"
echo "Get the current CVEs for the Host $HOST"
getallvulnerabilities=$(lacework api post api/v2/Vulnerabilities/Hosts/search -d '{ "filters": [ { "field": "severity", "expression": "eq", "value": "Medium" }, { "field": "severity", "expression": "eq", "value": "Critical" }, { "field": "severity", "expression": "eq", "value": "High" }, { "field": "severity", "expression": "eq", "value": "Low" }, { "field": "severity", "expression": "eq", "value": "Info" }, { "field": "fixInfo.fix_available", "expression": "eq", "value": "1" }, { "field": "evalCtx.hostname", "expression": "eq", "value": "'$HOST'" } ], "returns": [ "vulnId" ] }')
vulnerabilities=$(echo $getallvulnerabilities | jq -r '.data | map(.vulnId) | @csv')
echo "The following Vulnerabilities have been found:"
echo $vulnerabilities
sleep 5
echo "Adding a new Vulnerability Exception with the current CVEs for the Host $HOST"
lacework api post api/v2/VulnerabilityExceptions -d '{ "exceptionName": "All CVEs for host '$HOST'", "exceptionReason": "Fix Pending", "vulnerabilityCriteria": { "cve": [ '$vulnerabilities' ] }, "exceptionType": "Host", "props": { "description": "Added all CVEs as exception for the host '$HOST'" }, "resourceScope": { "hostname": [ "'$HOST'" ] } }'
