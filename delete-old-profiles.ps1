# Quick script to delete old user accounts after windows server upgrade
# Requires powershell 6, run as admin. 

# Make all errors terminating. Makes some try..catch blocks actually work.
$ErrorActionPreference = "Stop"; 

# Get info on all profiles on local machine
$localpaths = Get-CimInstance  -Class Win32_UserProfile | Select-Object  -Property LocalPath

foreach($path in $localpaths){
	# Converts it to an array
	$path = $path | Out-String -Stream 
	
	# path is now an object array, the LocalPath is in the third position
	$path = $path[3] 
	"Path is " + $path
	
	# If it's from the old domain, and is not the local machine netlab account, delete it!
	if(!$path.endsWith('TM') -and $path.startsWith('C:\Users\') -and !$path.endswith('netlab') -and !$path.endswith('Public') -and !$path.endswith('Default')){
		try{
			"Deleting " + $path + "..."
			Get-CimInstance -Class Win32_UserProfile | where {($_.LocalPath -eq $path)} | Remove-CimInstance  
		}catch{
			"Error deleting the entire profile!"
			"*** Manually delete the profile directory at " + $path + " ***"
		}
	}
}
