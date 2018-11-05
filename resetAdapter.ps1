import-module NetAdapter

# Adapter names that should be reset
$lan_adapter = "LAN Connection"
$internet_adapter = "Internet Connection"

# Array containing all of the adapters
$all_adapters = @($lan_adapter,$internet_adapter)

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
}