
# Make all errors terminating. Makes some try..catch blocks actually work.
$ErrorActionPreference = "Stop"; 

# ADAPTER GLOBALS
$INTERNET_CONNECTION_ADAPTER_NAME = "Internet Connection"
$LAN_CONNECTION_ADAPTER_NAME = "LAN Connection"

# Flags for whether DNS entries should be made for each adapter.
$REGISTER_DNS_INTERNET_CONNECTION = $false
$REGISTER_DNS_LAN_CONNECTION = $true

# Whether or not script should still add the domain specific persistent routes 
# when the LAN Connection adapter doesn't have an IP like 10.0.X.Y
# If true, the domain number will be obtained from the hostname instead of the IP
$ADD_DOM_ROUTES_WHEN_CONFIG_BAD = $true

# Highest domain num (dom1 - dom6 in this case)
$MAX_DOMAIN_NUM = 6

############################################
#            ADAPTER SETTINGS              #
############################################

# Get names of all adapters on PC
$all_adapters = Get-NetAdapter | Select-Object -ExpandProperty "Name"

# Stores domain number this PC resides in
$domain_num


foreach($adapter_name in $all_adapters){

	# Enable the adapter if it's disabled
	Enable-NetAdapter -Name $adapter_name

	$IPType = "IPv4"

	# Get adapter & its ipv4 interface
	$adapter = Get-NetAdapter -Name $adapter_name
	$interface = $adapter | Get-NetIPInterface -AddressFamily $IPType

	# Check if DHCP is disabled
	If ($interface.Dhcp -eq "Disabled") {
		"Reverting " + $adapter_name + " to DHCP..."
		
		# Remove existing gateway(s) from adapter
		If (($interface | Get-NetIPConfiguration).Ipv4DefaultGateway) {
			netsh interface ipv4 set address name=$adapter_name source=dhcp
		}

		# Enable DHCP
		$interface | Set-NetIPInterface -DHCP Enabled
		$interface | Set-NetIPInterface -AddressFamily "IPv4"
		
		# Renew DHCP 
		ipconfig /release $adapter_name
		ipconfig /renew $adapter_name
		
		# Restart Adapter. This seems to be necessary to prevent a crash
		"Restarting Adapter..."
		Restart-NetAdapter -name $adapter_name
		
		# Sleep to make sure adapter restarts successfully
		Start-Sleep -Seconds 20
	}
	
	# Make sure metric is automatic and not manually assigned
	# May cause error right after DHCP reset, but doesn't really matter.
	$interface | Set-NetIPInterface -AutomaticMetric Enabled

	# Configure the DNS Servers automatically
	$interface | Set-DnsClientServerAddress -ResetServerAddresses
	
	# Get IP Address of adapter
	$ipv4_address = $adapter | Get-NetIPAddress -AddressFamily IPv4 | Select-Object -ExpandProperty "IPAddress"
	
	# If adapter has IP starting with 10.0.0.X
	If ($ipv4_address.StartsWith("10.0.0.")) {
	
		If (!($adapter_name -eq $INTERNET_CONNECTION_ADAPTER_NAME)){
			# Rename adapter
			Rename-NetAdapter -Name $adapter_name -NewName $INTERNET_CONNECTION_ADAPTER_NAME
		}
		
		# Prevent internet adapter from DNS registration
		$adapter | set-dnsclient -RegisterThisConnectionsAddress $REGISTER_DNS_INTERNET_CONNECTION
	}
	
	# If adapter has IP starting with 10.0.X.Y (domain adapter)
	elseif ($ipv4_address.StartsWith("10.0.")){
		
		If (!($adapter_name -eq $LAN_CONNECTION_ADAPTER_NAME)){
			# Rename it.
			Rename-NetAdapter -Name $adapter_name -NewName $LAN_CONNECTION_ADAPTER_NAME
		}
		
		# GETTING DOMAIN NUM FROM IP ADDRESS...
		# This assumes the switch/router are set up correctly
		$last_dot = $ipv4_address.LastIndexOf(".")
		$dot_before_last_dot = $ipv4_address.LastIndexOf(".",$last_dot - 1)  + 1
		# Get substring of IP address to get domain_num. Second arg of .substring() is the length of substring 
		$domain_num = $ipv4_address.substring($dot_before_last_dot,($last_dot - $dot_before_last_dot))
		"Domain number is " + $domain_num
		
		# Allow domain adapter to do DNS registration
		$adapter | set-dnsclient -RegisterThisConnectionsAddress $REGISTER_DNS_LAN_CONNECTION 
	}
}

if($ADD_DOM_ROUTES_WHEN_CONFIG_BAD){
	# GETTING DOMAIN NUM FROM HOSTNAME...
	# If it fails to get the domain number from the LAN Connection Adapter, try to extract it from the PC hostname
	# This will make sure the domain routes get added no matter what
	if(!$domain_num){
		$hostname = Hostname
		for($i=1;$i -lt $hostname.length;$i++){
			# Start substring at char 3 in 'domXpcY'
			Try{
				# Try to typecast to an int
				$dn = [int]$hostname.substring(3,$i)
				$domain_num = $dn
			} Catch{ 				
				# If the substring is not an int, exit loop
				break
			}
		}
		"Domain number is " + $domain_num
	}
}
############################################
#            PERSISTENT ROUTES             #
############################################

"Deleting routes..."
# Remove existing routes
route delete 0.0.0.0
route delete 10.0.0.0

###########################
### Internet Connection ### 
###########################

"Configuring routes for " + $INTERNET_CONNECTION_ADAPTER_NAME + "..."
# Get adapter by name
$adapter = Get-NetAdapter -Name $INTERNET_CONNECTION_ADAPTER_NAME
# Getting interface index (necessary for persistent routes to become active)
# Not specifiying an interface index can result in the wrong interface being used for a route.
$interface_index = $adapter | Select-Object -ExpandProperty InterfaceIndex

# Add persistent route
# Direct traffic not destined for another domain through the "Internet Connection" adapter.
route -p add 0.0.0.0 mask 0.0.0.0 10.0.0.3 if $interface_index
route -p add 10.0.0.0 mask 255.255.255.0 10.0.0.3 if $interface_index

######################
### LAN Connection ### 
######################

"Configuring routes for " + $LAN_CONNECTION_ADAPTER_NAME + "..."
# Get adapter by name
$adapter = Get-NetAdapter -Name $LAN_CONNECTION_ADAPTER_NAME
# Getting interface index (necessary for persistent route to become active)
$interface_index = $adapter | Select-Object -ExpandProperty InterfaceIndex

# Add persistent routes. Direct domain router traffic.
# If traffic is destined for another domain (10.0.X.Y), route it through the domain router.
# If the domain_num was not obtained due to faulty router settings, these routes wont be added.
for($i=1;$i -le $MAX_DOMAIN_NUM;$i++){
	route delete 10.0.$i.0
	route -p add 10.0.$i.0 mask 255.255.255.0 10.0.$domain_num.1 if $interface_index
}

############################################
#            ENABLE FIREWALL               #
############################################
# "Enabling Firewall..."
# Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled NotConfigured

############################################
#            DISABLE PROXY                 #
############################################
"Disabling Proxy..."
set-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -value 0 

############################################
#            REMOTE DESKTOP                #
############################################
# https://exchangepedia.com/2016/10/enable-remote-desktop-rdp-connections-for-admins-on-windows-server-2016.html

# Enable RDP Connections
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0

# Enable Network Level Authentication
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 1

Try{
	# Check if the rule exists.
	Get-NetFirewallRule -DisplayGroup "Remote Desktop"
	"RDP FW Rule already exists."
} Catch{
	# Enable Windows firewall rules to allow incoming RDP
	"Adding RDP FW Rule..."
	Enable-NetFirewallRule -DisplayGroup “Remote Desktop”
}
############################################
#            TFTP FIREWALL RULE            #
############################################
# TFTP uses port 69 w/ UDP. This adds a new rule that allows it.
# This should make configuring tftpd64's firewall rules unecessary.
Try{
	# Check if the rule exists.
	Get-NetFirewallRule -DisplayName "TFTP"
	"TFTP FW Rule Already exists."
} Catch{
	"Adding TFTP FW Rule..."
	New-NetFirewallRule -DisplayName 'TFTP' -Profile @('Domain', 'Private', 'Public') -Direction Inbound -Action Allow -Protocol UDP -LocalPort '69'
}


