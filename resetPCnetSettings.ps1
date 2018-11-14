############################################
#            ADAPTER SETTINGS              #
############################################

# Get names of all adapters on PC
$all_adapters = Get-NetAdapter | Select-Object -ExpandProperty "Name"

foreach($adapter_name in $all_adapters){

	# Enable the adapter if it's disabled
	Enable-NetAdapter -Name $adapter_name

	$IPType = "IPv4"

	# Get adapter & its ipv4 interface
	$adapter = Get-NetAdapter -Name $adapter_name
	$interface = $adapter | Get-NetIPInterface -AddressFamily $IPType

	# Check if DHCP is disabled
	If ($interface.Dhcp -eq "Disabled") {

		# Remove existing gateway
		If (($interface | Get-NetIPConfiguration).Ipv4DefaultGateway) {
			$interface | Remove-NetRoute -Confirm:$false
		}

		# Enable DHCP
		$interface | Set-NetIPInterface -DHCP Enabled

		# Configure the DNS Servers automatically
		$interface | Set-DnsClientServerAddress -ResetServerAddresses
	}
	# Get IP Address of adapter
	$ipv4_address = $adapter | Get-NetIPAddress -AddressFamily IPv4 | Select-Object -ExpandProperty "IPAddress"
	
	# If adapter has IP starting with 10.0.0.X
	If ($ipv4_address.StartsWith("10.0.0.")) {
		Rename-NetAdapter -Name $adapter_name "Internet Connection"
	}
	# If adapter has IP starting with 10.0.X.Y (domain adapter)
	elseif ($ipv4_address.StartsWith("10.0.")){
		Rename-NetAdapter -Name $adapter_name "LAN Connection"
	}
}

############################################
#            PERSISTENT ROUTES             #
############################################

# Remove existing routes
route delete 0.0.0.0
route delete 10.0.0.0

# Get adapter by name
$adapter = Get-NetAdapter -Name "Internet Connection"
# Getting interface index
$interface_index = $adapter | Select-Object -ExpandProperty InterfaceIndex

# Add persistent route
route -p add 0.0.0.0 mask 0.0.0.0 10.0.0.3 if $interface_index

# Get adapter by name
$adapter = Get-NetAdapter -Name "LAN Connection"
# Getting interface index
$interface_index = $adapter | Select-Object -ExpandProperty InterfaceIndex

route -p add 10.0.0.0 mask 255.255.255.0 10.0.3.1  if $interface_index


############################################
#            ENABLE FIREWALL               #
############################################
echo "Enabling Firewall..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
