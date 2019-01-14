# pwsh-store

Logon Script - For static routes, firewall rules, and adapter/interface settings. Also disables proxy if that was turned on for some reason.

Optional Features - For installing telnet client and WSL. WSL installation process still a WIP. This script probably won't be used.

TCL Scripts - These create a script call reset.tcl on Cisco switches or routers that support tclsh. Running the script will reset the device, clearing extra settings a normal `copy startup-config running-config` wouldn't. To run the script, after it has been put on the device, do `tclsh flash:reset.tcl`. This uses the current `startup-config` as a basis for how the device should be configured. If your `startup-config` is messed up, fix that first.
