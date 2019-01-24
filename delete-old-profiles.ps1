# Quick script to delete old user accounts after windows server upgrade
# Probably needs PS version 6+ due to a bug with Remove-Item and symlinks in 5

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
			"Threw an error. Deleting profile path at " + $path
			Remove-Item -path $path -recurse -force
		}
	}
}
