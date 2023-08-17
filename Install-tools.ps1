<#
.SYNOPSIS
  Tools installation script
.DESCRIPTION
  This script will download and install tools in the C:\Toolbox folder and create a shortcut on the desktop
.PARAMETER <Parameter_Name>
  None
.INPUTS
  None
.OUTPUTS
  Log file in C:\<user>\AppData\Local\Temp\scripts_output\Get-tools.txt
.NOTES
  Version:        1.0
  Author:         Adrien STAULUS
  Creation Date:  17/08/2023
  Purpose/Change: Download and install tools
  
.EXAMPLE
  None
#>

#---------------------------------------------------------[Test]--------------------------------------------------------


#Check if run as admin
#requires -RunAsAdministrator


#Check for ps version
#Requires -Version 5.1


#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Logs
$scriptname = "install-tools.txt"
$logpath = "$env:TEMP\scripts_output\$scriptname"

$icon_url = "https://www.iconarchive.com/download/i47384/icons-land/vista-hardware-devices/Toolbox-Red.ico"
$icon_destination ="C:\Toolbox\icon\Toolbox-Red.ico"


$Locations = @( 
"C:\users\administrateur\desktop",
"C:\users\administrator\desktop",
"C:\users\adrsta\desktop"
)

$download_list= @( 
"https://www.voidtools.com/Everything-1.4.1.1024.x64.zip",
"https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe",
"https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe",
"https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe",
"https://download.sysinternals.com/files/ProcessExplorer.zip",
"https://download.sysinternals.com/files/ProcessMonitor.zip",
"https://download.sysinternals.com/files/RAMMap.zip",
"https://download.sysinternals.com/files/TCPView.zip",
"https://download.sysinternals.com/files/PSTools.zip",
"https://diskanalyzer.com/files/wiztree_4_15_portable.zip",
"https://www.nirsoft.net/utils/pinginfoview.zip"
)



#-----------------------------------------------------------[Functions]------------------------------------------------------------



function Start-Download {
	param(
		[Parameter(Mandatory)]
		[string]$Url,

		[Parameter(Mandatory)]
		[string]$Destination
	)
	process {
		$WebClient = New-Object System.Net.WebClient  # create a system.net.webclient object
        $WebClient.DownloadFile($Url,$Destination) #add parameters to the system.net.webclient object and invoke the download method
	}
}



function read-zipfile {
	param(
		[Parameter(Mandatory)]
		[string]$File,

		[Parameter(Mandatory)]
		[string]$Destination
	)
    process {
		Expand-Archive -LiteralPath $File -DestinationPath $destination
	}
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
Start-Transcript -Path $logpath  -Append 

#create tool & icon folder
new-item -Type Directory C:\Toolbox\icon | Out-Null
write-host "Creating folders C:\Toolbox\icon" -f green


write-host "Downloading icon `n" -f green
#download icon
Start-Download -Url $icon_url -Destination $icon_destination

#loop through the array and create the shortcut in the different locations
foreach ($location in $locations) {
  if (test-path $location) {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$Location\Toolbox.lnk")
    $shortcut.TargetPath = 'C:\Toolbox\'
    $shortcut.IconLocation = "$icon_destination"
    $shortcut.Save()
  }
}

#loop through the array and download and unzip (if necessary) all the tools in their respective folder

foreach ($link in $download_list) {
    $file = split-path -Leaf $link
    $file_wo_ext = [io.path]::GetFileNameWithoutExtension("$file")
    Write-host "[###############################] `n"
    Write-host "Creating folder $file_wo_ext `n"
    New-Item -ItemType Directory -Path "C:\toolbox\$file_wo_ext" | Out-Null
    $destination = "C:\toolbox\$file_wo_ext\$file"
    $destinationnotzip = "C:\toolbox\$file_wo_ext\"
    Write-Host "Downloading... " -f white -nonewline; Write-Host "$file " -f Cyan -nonewline; Write-Host "[" -f white -nonewline; Write-Host "=>" -f green -nonewline; Write-Host "]" -f white -nonewline; write-host "`n" 
    Start-Download -Url $link -Destination $destination
    if ($file -like "*.zip") {
        read-zipfile -File $destination -Destination $destinationnotzip
        Remove-Item $destination
    }
  }

Stop-Transcript
Invoke-Item $logpath
remove-item $logpath
#-----------------------------------------------------------[End]------------------------------------------------------------






