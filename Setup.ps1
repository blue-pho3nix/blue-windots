
<#PSScriptInfo

.VERSION 1

.TAGS windots dotfiles

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>

#Requires -Version 7
#Requires -RunAsAdministrator




<#

.DESCRIPTION
	Configs script for Windows 11 Machine.

#>
Param()

$VerbosePreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

########################################################################################################################
###	HELPER FUNCTIONS										             ###
########################################################################################################################
function Write-TitleBox {
	param ([string]$Title, [string]$BorderChar = "*", [int]$Padding = 10)

	$Title = $Title.ToUpper()
	$titleLength = $Title.Length
	$boxWidth = $titleLength + ($Padding * 2) + 2

	$borderLine = $BorderChar * $boxWidth
	$paddingLine = $BorderChar + (" " * ($boxWidth - 2)) + $BorderChar
	$titleLine = $BorderChar + (" " * $Padding) + $Title + (" " * $Padding) + $BorderChar

	''
	Write-Host $borderLine -ForegroundColor Cyan
	Write-Host $paddingLine -ForegroundColor Cyan
	Write-Host $titleLine -ForegroundColor Cyan
	Write-Host $paddingLine -ForegroundColor Cyan
	Write-Host $borderLine -ForegroundColor Cyan
	''
}

# Source:
# - https://stackoverflow.com/questions/2688547/multiple-foreground-colors-in-powershell-in-one-command
function Write-ColorText {
	param ([string]$Text, [switch]$NoNewLine)

	$hostColor = $Host.UI.RawUI.ForegroundColor

	$Text.Split( [char]"{", [char]"}" ) | ForEach-Object { $i = 0; } {
		if ($i % 2 -eq 0) {	Write-Host $_ -NoNewline }
		else {
			if ($_ -in [enum]::GetNames("ConsoleColor")) {
				$Host.UI.RawUI.ForegroundColor = ($_ -as [System.ConsoleColor])
			}
		}
		$i++
	}

	if (!$NoNewLine) { Write-Host }
	$Host.UI.RawUI.ForegroundColor = $hostColor
}

function Add-ScoopBucket {
	param ([string]$BucketName, [string]$BucketRepo)

	$scoopDir = (Get-Command scoop.ps1 -ErrorAction SilentlyContinue).Source | Split-Path | Split-Path
	if (!(Test-Path "$scoopDir\buckets\$BucketName" -PathType Container)) {
		if ($BucketRepo) {
			scoop bucket add $BucketName $BucketRepo
		} else {
			scoop bucket add $BucketName
		}
	} else {
		Write-ColorText "{Blue}[bucket] {Magenta}scoop: {Yellow}(exists) {Gray}$BucketName"
	}
}


function Install-WinGetApp {
    param ([string]$PackageID, [array]$AdditionalArgs, [string]$Source)

    Write-Host "Checking if package '$PackageID' is already installed..." -ForegroundColor Cyan

    # Define a variable to track existence
    $_packageExists = $false

    # Run winget list and check exit code
    Write-Host "Running: winget list --exact --id $PackageID" -ForegroundColor Gray
    $listResult = winget list --exact --id $PackageID # Using --id is sometimes more reliable

    # Check the exit code of the list command explicitly
    if ($LASTEXITCODE -ne 0) {
        # It failed OR the package wasn't found (winget list exits with non-zero if not found)
        Write-Host "Package '$PackageID' not found or 'winget list' failed. Proceeding with install attempt..." -ForegroundColor Yellow
        $_packageExists = $false
    } else {
        # Package exists
        Write-Host "Package '$PackageID' found." -ForegroundColor Green
        $_packageExists = $true
    }

    # Proceed with installation only if the package does not exist
    if ($_packageExists -eq $false) {
        Write-Host "Preparing installation command for '$PackageID'..." -ForegroundColor Yellow

        # Build arguments for Start-Process
        $wingetProcessArgs = @("install", "--id", $PackageID)

        # Add arguments from AppList.json
        if ($AdditionalArgs.Count -ge 1) {
            $wingetProcessArgs += $AdditionalArgs
        }

        # Add source argument
        if ($Source -eq "msstore") {
            $wingetProcessArgs += "--source", "msstore"
        } else {
            # Default to winget source if not specified or not msstore
            $wingetProcessArgs += "--source", "winget"
        }

        # Ensure required arguments for silent install are present
        if (!($wingetProcessArgs -contains "--accept-package-agreements")) {
            $wingetProcessArgs += "--accept-package-agreements"
            Write-Verbose "Adding --accept-package-agreements for $PackageID"
        }
        if (!($wingetProcessArgs -contains "--accept-source-agreements")) {
            $wingetProcessArgs += "--accept-source-agreements"
             Write-Verbose "Adding --accept-source-agreements for $PackageID"
        }
        # Double-check for --silent, although it should be in your AppList.json
        if (!($wingetProcessArgs -contains "--silent")) {
             Write-Warning "The --silent argument seems missing for $PackageID. Installation might require user interaction."
             # Consider forcing it if necessary: $wingetProcessArgs += "--silent"
        }

        $commandStringForDisplay = "winget $($wingetProcessArgs -join ' ')"
        Write-Host "Executing: $commandStringForDisplay" -ForegroundColor Magenta

        try {
            # Use Start-Process -Wait instead of Invoke-Expression
            $process = Start-Process winget -ArgumentList $wingetProcessArgs -Wait -PassThru -ErrorAction Stop -Verbose:$false

            # Check the Exit Code after waiting
            if ($process.ExitCode -eq 0) {
                Write-ColorText "{Blue}[package] {Magenta}winget: {Green}(success) {Gray}$PackageID"
            } else {
                # Report specific non-zero exit code
                Write-ColorText "{Blue}[package] {Magenta}winget: {Red}(failed - Exit Code $($process.ExitCode)) {Gray}$PackageID"
                Write-Warning "Winget failed for $PackageID. Exit Code: $($process.ExitCode). Check logs or try installing manually."
            }
        } catch {
            # Catch errors if Start-Process itself fails (e.g., winget not found)
            Write-Error "Failed to start winget process for $PackageID`: $_"
            Write-ColorText "{Blue}[package] {Magenta}winget: {Red}(failed - Exception executing winget) {Gray}$PackageID"
        }

    } else {
         # This block runs if the package was found by 'winget list'
        Write-ColorText "{Blue}[package] {Magenta}winget: {Yellow}(exists) {Gray}$PackageID"
    }
}



function Refresh ([int]$Time) {
    # Determine the suffix for the attempt number (optional, kept for consistency)
    $suffix = switch -regex ($Time.ToString()) {
        '1(1|2|3)$' { 'th'; break }
        '.?1$' { 'st'; break }
        '.?2$' { 'nd'; break }
        '.?3$' { 'rd'; break }
        default { 'th'; break }
    }

    Write-Verbose -Message "Refreshing environment variables from registry ($Time$suffix attempt)"

    # Update environment variables for the current process
    # This reads User and Machine variables from the registry and updates the process
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # Reload other environment variables (iterate through registry)
    Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment', 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' |
        ForEach-Object {
            # Access the .PSObject member, then its .Properties collection
            $_.PSObject.Properties
        } |
        ForEach-Object {
            # $_ is now a PSPropertyInfo object with .Name and .Value
            # Skip internal PS-prefixed properties AND the Path variable (handled above)
            if ($_.Name -notlike 'PS*' -and $_.Name -ne 'Path') {
                [System.Environment]::SetEnvironmentVariable($_.Name, $_.Value, "Process")
                Write-Verbose "Refreshed variable '$($_.Name)' in current session."
            }
        }

    Write-Host "Environment variables refreshed for the current session." -ForegroundColor DarkGray
}


function Write-LockFile {
	param (
		[ValidateSet('winget', 'scoop', 'modules')]
		[Alias('s', 'p')][string]$PackageSource,
		[Alias('f')][string]$FileName,
		[Alias('o')][string]$OutputPath = "$PSScriptRoot\out"
	)

	$dest = "$OutputPath\$FileName"

	switch ($PackageSource) {
		"winget" {
			if (!(Get-Command winget -ErrorAction SilentlyContinue)) { return }
			winget export -o $dest | Out-Null
			if ($LASTEXITCODE -eq 0) {
				Write-ColorText "`nPackages installed by {Green}$PackageSource {Gray}are exported at {Green}$((Resolve-Path $dest).Path)"
			}
			Start-Sleep -Seconds 1
		}
		"scoop" {
			if (!(Get-Command scoop -ErrorAction SilentlyContinue)) { return }
			scoop export -c > $dest
			if ($LASTEXITCODE -eq 0) {
				Write-ColorText "`nPackages installed by {Green}$PackageSource {Gray}are exported at {Red}$((Resolve-Path $dest).Path)"
			}
			Start-Sleep -Seconds 1
		}
		"modules" {
			Get-InstalledModule | Select-Object -Property Name, Version | ConvertTo-Json -Depth 100 | Out-File $dest
			if ($LASTEXITCODE -eq 0) {
				Write-ColorText "`n{Green}PowerShell Modules {Gray}installed are exported at {Red}$((Resolve-Path $dest).Path)"
			}
			Start-Sleep -Seconds 1
		}
	}
}


########################################################################
###		MAIN SCRIPT 		  			     ###
########################################################################
# if not internet connection, then we will exit this script immediately
$internetConnection = Test-NetConnection google.com -CommonTCPPort HTTP -InformationLevel Detailed -WarningAction SilentlyContinue
$internetAvailable = $internetConnection.TcpTestSucceeded
if ($internetAvailable -eq $False) {
	Write-Warning "NO INTERNET CONNECTION AVAILABLE!"
	Write-Host "Please check your internet connection and re-run this script.`n"
	for ($countdown = 3; $countdown -ge 0; $countdown--) {
		Write-ColorText "`r{DarkGray}Automatically exit this script in {Blue}$countdown second(s){DarkGray}..." -NoNewLine
		Start-Sleep -Seconds 1
	}
	exit
}

Write-Progress -Completed

Write-ColorText "`n{Green}Internet Connection available.`n`n{DarkGray}Start running setup process..."
Start-Sleep -Seconds 3

# set current working directory location
$currentLocation = "$($(Get-Location).Path)"

Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

$i = 1


########################################################################
###	WINGET PACKAGES 			 		     ###
########################################################################
# Retrieve information from json file
$json = Get-Content "$PSScriptRoot\appList.json" -Raw | ConvertFrom-Json

# Winget Packages
Write-TitleBox -Title "WinGet Packages Installation"
$wingetItem = $json.installSource.winget
$wingetPkgs = $wingetItem.packageList
$wingetArgs = $wingetItem.additionalArgs
$wingetInstall = $wingetItem.autoInstall

if ($wingetInstall -eq $True) {
	if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
		# Use external script to install WinGet and all of its requirements
		# Source: - https://github.com/asheroto/winget-install
		Write-Verbose -Message "Installing winget-cli"
		&([ScriptBlock]::Create((Invoke-RestMethod asheroto.com/winget))) -Force
	}

	# Configure winget settings for BETTER PERFORMANCE
	# Note that this will always overwrite existed winget settings file whenever you run this script
	$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
	$settingsJson = @'
{
		"$schema": "https://aka.ms/winget-settings.schema.json",

		// For documentation on these settings, see: https://aka.ms/winget-settings
		// "source": {
		//    "autoUpdateIntervalInMinutes": 5
		// },
		"visual": {
				"enableSixels": true,
				"progressBar": "rainbow"
		},
		"telemetry": {
				"disable": true
		},
		"experimentalFeatures": {
				"configuration03": true,
				"configureExport": true,
				"configureSelfElevate": true,
				"experimentalCMD": true
		},
		"network": {
				"downloader": "wininet"
		}
}
'@
	$settingsJson | Out-File $settingsPath -Encoding utf8

	# Download packages from WinGet
	foreach ($pkg in $wingetPkgs) {
		$pkgId = $pkg.packageId
		$pkgSource = $pkg.packageSource
		if ($null -ne $pkgSource) {
			Install-WinGetApp -PackageID $pkgId -AdditionalArgs $wingetArgs -Source $pkgSource
		} else {
			Install-WinGetApp -PackageID $pkgId -AdditionalArgs $wingetArgs
		}
	}
	Write-LockFile -PackageSource winget -FileName wingetfile.json
}

Refresh ($i++)


########################################################################
###                   SCOOP PACKAGES INSTALLATION                   ###
########################################################################
Write-TitleBox -Title "Scoop Pacakages Installation"

# Check if Scoop is installed
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop not found. Installing Scoop..." -ForegroundColor Cyan
    # Run the installer and let all output show
    iex "& { $(iwr 'https://get.scoop.sh') } -RunAsAdmin"
}

# Add Scoop shims to PATH immediately
$ScoopShims = "$env:USERPROFILE\scoop\shims"
if (-not ($env:PATH -like "*$ScoopShims*")) {
    $env:PATH += ";$ScoopShims"
}

# Make sure extras bucket is added
if (-not (scoop bucket list | Select-String "extras")) {
    Write-Host "Adding 'extras' bucket..." -ForegroundColor Cyan
    # Show all output
    scoop bucket add extras | Write-Host
}

# Install AutoHotkey (only if not already installed)
if (-not (scoop list | Select-String "autohotkey")) {
    Write-Host "Installing AutoHotkey..." -ForegroundColor Cyan
    # Use Start-Process to show live output
    Start-Process -FilePath "scoop" -ArgumentList "install autohotkey" -NoNewWindow -Wait
} else {
    Write-Host "AutoHotkey is already installed." -ForegroundColor Green
}

Write-Host "Scoop + AutoHotkey installation complete." -ForegroundColor Green

Refresh ($i++)

######################################################################
###		NERD FONTS					   ###
######################################################################
# install nerd fonts
Write-TitleBox -Title "Nerd Fonts Installation"

# Check if Oh My Posh is installed and available in the PATH
$omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue

if ($null -ne $omp) {
	Write-ColorText "{Green}Found 'oh-my-posh'. Attempting to install '0xProto Nerd Font'..."
	Write-ColorText "{Gray}(This may take a moment...)"

	try {
		# Execute the oh-my-posh font installer for 0xProto
		# We add -ErrorAction Stop to catch errors in the 'catch' block
		oh-my-posh font install 0xProto
		
		Write-ColorText "`n{Green}Successfully installed '0xProto Nerd Font'."
		Write-ColorText "{Yellow}You MUST restart your terminal (e.g., Windows Terminal, VS Code) for the new font to be available."
	}
	catch {
		Write-ColorText "{Red}An error occurred while installing the font:"
		Write-ColorText "{Gray}$($_.Exception.Message)"
	}
}
else {
	Write-ColorText "{Red}Error: 'oh-my-posh.exe' not found in your $env:PATH."
	Write-ColorText "{Yellow}Please ensure Oh My Posh is installed and accessible."
	Write-ColorText "{Gray}Skipping Nerd Font installation..."
}


##########################################################################
###                         CLINK CONFIGURATION                        ###
##########################################################################
Write-TitleBox -Title "Clink Configuration"

# Disable Clink banner/logo
Write-ColorText "{Cyan}Disabling Clink banner..."
# Full path to Clink executable
$clinkExe = "C:\Program Files (x86)\clink\clink_x64.exe"

# Check if the executable exists
if (Test-Path $clinkExe) {
    & $clinkExe set clink.logo none
    Write-ColorText "{Green}Clink banner disabled."
} else {
    Write-ColorText "{Yellow}Clink executable not found at $clinkExe. Skipping banner disable."
}

Refresh ($i++)


####################################################################
###	            COPY FILES 	                                 ###
####################################################################
# Copy dotfiles
Write-TitleBox -Title "Copy dotfiles to user profile"

# Define source and destination
$source = "$PSScriptRoot\config\home"
$destination = "$env:USERPROFILE"

# Copy all files and folders from the source to the destination
Write-ColorText "{Blue}[copy] {Green}Copying all files from $source... {Yellow}to {Gray}$destination"

# The \* copies the *contents* of the source folder, not the folder itself.
Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force -ErrorAction SilentlyContinue

Write-ColorText "{Green}All files copied successfully."



##########################################################################
###	ENVIRONMENT VARIABLES				               ###
##########################################################################
Write-TitleBox -Title "Set Environment Variables"
$envVars = $json.environmentVariable
foreach ($env in $envVars) {
	$envCommand = $env.commandName
	$envKey = $env.environmentKey
	$envValue = $env.environmentValue
	if (Get-Command $envCommand -ErrorAction SilentlyContinue) {
		if (![System.Environment]::GetEnvironmentVariable("$envKey")) {
			Write-Verbose "Set environment variable of $envCommand`: $envKey -> $envValue"
			try {
				[System.Environment]::SetEnvironmentVariable("$envKey", "$envValue", "User")
				Write-ColorText "{Blue}[environment] {Green}(added) {Magenta}$envKey {Yellow}--> {Gray}$envValue"
			} catch {
				Write-Error -ErrorAction Stop "An error occurred: $_"
			}
		} else {
			$value = [System.Environment]::GetEnvironmentVariable("$envKey")
			Write-ColorText "{Blue}[environment] {Yellow}(exists) {Magenta}$envKey {Yellow}--> {Gray}$value"
		}
	}
}

Refresh ($i++)


##########################################################################
###                 STARSHIP SETUP                                     ###
##########################################################################
Write-TitleBox "Starship Setup"

Write-Host "Configuring Starship for PowerShell..." -ForegroundColor Cyan

# The line to add
$initLine = 'Invoke-Expression (&starship init powershell)'

# Get current user's PowerShell profile path
$profilePath = $PROFILE

# Make sure the profile file exists
if (!(Test-Path -Path $profilePath)) {
    Write-Host "Profile not found, creating: $profilePath" -ForegroundColor Yellow
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# Add Starship initialization (avoid duplicates)
if (-not (Select-String -Path $profilePath -Pattern 'starship init powershell' -Quiet)) {
    Add-Content -Path $profilePath -Value "`n# >>> Starship Initialization >>>`n$initLine`n# <<< Starship Initialization <<<`n"
    Write-Host "Starship initialization added to: $profilePath" -ForegroundColor Green
} else {
    Write-Host "Starship already configured in: $profilePath" -ForegroundColor Yellow
}

Write-Host "Starship setup complete. Restart PowerShell to apply changes." -ForegroundColor Cyan



##########################################################################
###                       START KOMOREBI + YASB (WITH AUTOSTART)       ###
##########################################################################
Write-TitleBox "Komorebi & Yasb Engines"

# --- YASB ---
if (Get-Command yasbc -ErrorAction SilentlyContinue) {
    # 1. Create the autostart task if it doesn't exist
    # 'yasb-autostart' is the default name yasb creates
    if (!(Get-ScheduledTask -TaskName "yasb-autostart" -ErrorAction SilentlyContinue)) {
        Write-Host "Creating autostart task for YASB..."
        try {
            # Use the official command to create the autostart scheduled task
            yasbc enable-autostart --task
            Write-Host "YASB autostart task created." -ForegroundColor Green
        } catch {
            Write-Error "Failed to enable YASB autostart: $_"
        }
    } else {
        Write-Host "YASB autostart task already exists." -ForegroundColor Green
    }

    # 2. Start it for the current session if not running
    if (!(Get-Process -Name yasb -ErrorAction SilentlyContinue)) {
        Write-Host "Starting YASB for current session..."
        try { yasbc start } catch { Write-Error $_ }
    } else {
        Write-Host "YASB is already running." -ForegroundColor Green
    }
} else {
    Write-Warning "Command not found: yasbc."
}

# --- KOMOREBI ---
# Check if 'komorebic' command is available first
if (Get-Command komorebic -ErrorAction SilentlyContinue) {
    
    # 1. Set up autostart using the built-in command
    komorebic enable-autostart --ahk

    # 2. Start Komorebi, but only if it's not already running
    if (!(Get-Process -Name komorebi -ErrorAction SilentlyContinue)) {
        komorebic start --ahk
    }
    
} else {
    Write-Warning "komorebic command not found. Could not configure."
}


######################################################################
###		       END SCRIPT				   ###
######################################################################
Set-Location $currentLocation
Start-Sleep -Seconds 5

Write-Host "`n----------------------------------------------------------------------------------`n" -ForegroundColor DarkGray
Write-Host "┌────────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor "Green"
Write-Host "│                                                                                │" -ForegroundColor "Green"
Write-Host "│        █████╗ ██╗     ██╗         ██████╗  ██████╗ ███╗   ██╗███████╗ ██╗      │" -ForegroundColor "Green"
Write-Host "│       ██╔══██╗██║     ██║         ██╔══██╗██╔═══██╗████╗  ██║██╔════╝ ██║      │" -ForegroundColor "Green"
Write-Host "│       ███████║██║     ██║         ██║  ██║██║   ██║██╔██╗ ██║█████╗   ██║      │" -ForegroundColor "Green"
Write-Host "│       ██╔══██║██║     ██║         ██║  ██║██║   ██║██║╚██╗██║██╔══╝   ╚═╝      │" -ForegroundColor "Green"
Write-Host "│       ██║  ██║███████╗███████╗    ██████╔╝╚██████╔╝██║ ╚████║███████╗ ██╗      │" -ForegroundColor "Green"
Write-Host "│       ╚═╝  ╚═╝╚══════╝╚══════╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ╚═╝      │" -ForegroundColor "Green"
Write-Host "│                                                                                │" -ForegroundColor "Green"
Write-Host "└────────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor "Green"

