# createexceptionforallcves
Creates a Vulnerability Exception in Lacework with all current CVEs
## Requirements
You need to have the Lacework CLI installed and configured with your environment.
configure the variable LW_PROFILE with your profile configured in the lacework cli. By default it uses the profile default.
## What it does?
The current script creates a simple Vulnerability Exception for all CVEs found for a specific host inside Lacework with the following filters applied:
- Critical CVEs with a fix
- High CVEs with a fix
- Low CVEs with a fix
- Info CVEs with a fix
The Exception will have a filter applied to the host, is not limited to a specific time. The current exception reason is "Fix Pending".
## Current limitations (room for improvement)
- The script is in the current version more or less static for all vulnerabilites where a security fix exists. We try to make it more optional.
## Updates
- v02: Adding capability to detect if the host exists, if a vulnerability exception already exists and if yes update the existing one instead of creating a new one.
- v03: Adding capability to filter for unique CVEs so every CVE in the exception list is only used once.
