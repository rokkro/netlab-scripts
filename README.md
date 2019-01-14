# netlab-scripts

Logon Script - For static routes, firewall rules, and adapter/interface settings. Also disables proxy if that was turned on for some reason.

Optional Features - For installing telnet client and WSL. WSL installation process still a WIP. This script probably won't be used.

TCL Scripts - These files contain the commands to create a script called reset.tcl on Cisco switches or routers that support tclsh. Running the script will reset the device, clearing extra settings a normal `copy startup-config running-config` wouldn't. To run the script, after it has been put on the device, do `tclsh flash:reset.tcl`. This uses the current `startup-config` as a basis for how the device should be configured. To put the script on a device, enter `tclsh`, paste in the tcl script, and `exit` the shell.
