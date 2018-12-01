
# WSL GLOBALS
$INSTALL_WSL = $true
$DISTRO_DOWNLOAD_URL = "https://aka.ms/wsl-ubuntu-1804"
$DISTRO_SAVE_LOCATION = "C:\distros\"
$DISTRO_NAME = "ubuntu1804"

############################################
#           OPTIONAL FEATURES              #
############################################
# Hide progress bars
$ProgressPreference = 'SilentlyContinue'

# Install telnet client
dism /online /Enable-Feature /NoRestart /FeatureName:TelnetClient 

if($INSTALL_WSL){
  # Install Windows Subsystem for Linux feature 
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

  # C:\distros\ubuntu1804
  $base_path = $DISTRO_SAVE_LOCATION + $DISTRO_NAME

  # Make sure base dirs exist
  if (!(Test-Path $DISTRO_SAVE_LOCATION)){
    mkdir -p $base_path
  }

  # See if .exe in dir exists (basic way of checking if distro was already downloaded). May break if WSL starts using multiple .exe's
  if (!(Test-Path -Path ($base_path + "/" + '*.exe') -PathType Leaf)){

    # C:\distros\ubuntu1804.appx
    $appx_name = $base_path + ".appx"
    # C:\distros\ubuntu1804.zip
    $zip_name = $base_path + ".zip"

    cd $DISTRO_SAVE_LOCATION

    "Downloading distro..."
    # Download distro at URL into file named C:\distros\ubuntu1804.appx
    Invoke-WebRequest -Uri $DISTRO_DOWNLOAD_URL -OutFile $appx_name -UseBasicParsing

    # Make the appx a zip file, then extract it into C:\distros\ubuntu1804\
    Rename-Item $appx_name $zip_name
    Expand-Archive $zip_name $base_path

    # Remove compressed files
    rm $zip_name

    # Add enviro variables
    $userenv = [System.Environment]::GetEnvironmentVariable("Path", "User")
    [System.Environment]::SetEnvironmentVariable("PATH", $userenv + $base_path, "User")

    cd $base_path
    # Run the downloaded distro installer. Install arg prevents bash from launching.
    iex "$base_path\*.exe install"
  }

}
