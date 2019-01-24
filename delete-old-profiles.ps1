# Quick script to delete old user accounts before windows server upgrade

# Get info on all profiles on local machine
$localpaths = Get-WMIObject -Class Win32_UserProfile | Select-Object  -Property LocalPath

foreach($path in $localpaths){
	# Converts it to an array
	$path = $path | Out-String -Stream 
	
	# path is now an object array, the LocalPath is in the third position
	$path = $path[3] 

	# If it's from the old domain, and is not the local machine netlab account, delete it!
	if(!$path.endsWith('TM') -and $path.startsWith('C:\Users\') -and !$path.endswith('netlab')){
		"Deleting " + $path + "..."
		Get-WMIObject -Class Win32_UserProfile | where {($_.LocalPath -eq $path)} | Remove-WMIObject  
	}
}
