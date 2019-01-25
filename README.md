# netlab-scripts

Logon Script - For static routes, firewall rules, and adapter/interface settings. Also disables proxy if that was turned on for some reason.

Optional Features - For installing telnet client and WSL. WSL installation process still a WIP. This script probably won't be used.

clear-local-group-policy - Attempts to clear local group policy settings that won't disappear after changing the OU group policy. Doesn't work to well at the moment, will probably look into fleshing this out when the need for this arises. 

pwsh#-delete-old-profiles - Deletes old profiles on a local machine that fall under `C:\Users\`. Edit the condition to make it match your needs. Two scripts - one for Powershell 5.X, and one for Powershell 6.X. Run as admin to make it work.

TCL Scripts - These files contain the commands to create a script called reset.tcl on Cisco switches or routers that support the tcl shell. Running the script will reset the device, clearing extra settings a normal `copy startup-config running-config` wouldn't (vlans, routes, etc). To run the script, after it has been put on the device, do `tclsh reset.tcl`. This uses the current `startup-config` as a basis for how the device should be configured. To put the script on a device, enter `tclsh`, paste in the tcl script, and `exit` the shell. 
