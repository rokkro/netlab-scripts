# Credit goes to the users from these websites
# https://luke.geek.nz/win/clear-local-workstations-group-policy-cache/
# https://social.technet.microsoft.com/Forums/en-US/70d26044-d896-4a6b-82c4-25ff263804ac/clearing-old-gpo-settings?forum=w7itprogeneral

"Removing registry keys..."
# Can't remove some of these, but it's worth a shot
REG DELETE HKCU\SOFTWARE\Policies\Microsoft /f
REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies /f
REG DELETE HKLM\SOFTWARE\Policies\Microsoft /f
REG DELETE HKLM\SOFTWARE\Policies\Microsoft /f
REG DELETE "HKCU\Software\Microsoft\Windows\Currentversion\Group Policy Objects" /f
REG DELETE HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies /f

"Deleting local GP files..."
$path = "$env:windir\system32\GroupPolicy"
if([System.IO.File]::Exists($path)){
  Remove-Item $path -Force -Recurse
}
$path = "C:\WINDOWS\security\Database\secedit.sdb"
if([System.IO.File]::Exists($path)){
  Remove-Item $path -Force
}
$path = "C:\ProgramData\Microsoft\Group Policy\History\"
if([System.IO.File]::Exists($path)){
  Remove-Item $path -Force -Recurse
}

"Clearing cached Kereberos tickets..."
# Probably not necessary here but why not?
Klist purge

# Update group policy
gpupdate /force
