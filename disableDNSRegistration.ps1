$computerNames = @()
for ($i = 1; $i -le 6; $i++) {
	for ($j = 1; $j -le 3; $j++) {
		$computerNames += ("DOM"+$i+"PC"+$j)
	}
}
foreach($pc in $computerNames) {
	Invoke-Command -ComputerName $pc -ScriptBlock {
		Get-NetAdapter -Name "LAN Connection" | set-dnsclient -RegisterThisConnectionsAddress $true
	}
}