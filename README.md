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
- The script does not check if there is already a Vulnerability Exception with the same name.
- You might see more CVEs applied as filter as you can see inside the UI view. This is due to that a CVE can be affecting multiple packages.
- The script is in the current version more or less static. We try to make it more optional.
