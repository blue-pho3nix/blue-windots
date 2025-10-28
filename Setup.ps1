
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
	Setup script for Windows 11 Machine.

#>
Param()

$VerbosePreference = "SilentlyContinue"

########################################################################################################################
###												  	HELPER FUNCTIONS												 ###
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


function Install-ScoopApp {
    param ([string]$Package, [switch]$Global, [array]$AdditionalArgs)

    Write-Host "Checking if Scoop package '$Package' is already installed..." -ForegroundColor Cyan

    # Check if package is installed using scoop list
    $_packageExists = $false
    Write-Host "Running: scoop list $Package" -ForegroundColor Gray
    $listOutput = scoop list $Package 2>&1 # Capture potential errors too
    if ($LASTEXITCODE -eq 0 -and $listOutput -notmatch "Couldn't find manifest for") {
         Write-Host "Package '$Package' found." -ForegroundColor Green
         $_packageExists = $true
    } else {
         Write-Host "Package '$Package' not found or 'scoop list' failed. Proceeding with install attempt..." -ForegroundColor Yellow
         $_packageExists = $false
    }

    if ($_packageExists -eq $false) {
        Write-Host "Preparing installation command for Scoop package '$Package'..." -ForegroundColor Yellow

        # Build arguments for Start-Process
        $scoopProcessArgs = @("install", $Package)

        if ($Global) {
            $scoopProcessArgs += "--global" # Use --global instead of -g for clarity
        }
        if ($AdditionalArgs.Count -ge 1) {
             # Ensure --global/-g isn't duplicated
             $FilteredArgs = $AdditionalArgs | Where-Object { $_ -ne "-g" -and $_ -ne "--global" }
             $scoopProcessArgs += $FilteredArgs
        }

        $commandStringForDisplay = "scoop $($scoopProcessArgs -join ' ')"
        Write-Host "Executing: $commandStringForDisplay" -ForegroundColor Magenta

        try {
            # Use Start-Process -Wait
            $process = Start-Process scoop -ArgumentList $scoopProcessArgs -Wait -PassThru -ErrorAction Stop -NoNewWindow -Verbose:$false

            # Check the Exit Code after waiting
            if ($process.ExitCode -eq 0) {
                Write-ColorText "{Blue}[package] {Magenta}scoop: {Green}(success) {Gray}$Package"
            } else {
                 # Report specific non-zero exit code
                Write-ColorText "{Blue}[package] {Magenta}scoop: {Red}(failed - Exit Code $($process.ExitCode)) {Gray}$Package"
                Write-Warning "Scoop failed for $Package. Exit Code: $($process.ExitCode). Check logs or try installing manually."
            }
        } catch {
            # Catch errors if Start-Process itself fails
            Write-Error "Failed to start scoop process for $Package`: $_"
            Write-ColorText "{Blue}[package] {Magenta}scoop: {Red}(failed - Exception executing scoop) {Gray}$Package"
        }

    } else {
        # Package already exists
        Write-ColorText "{Blue}[package] {Magenta}scoop: {Yellow}(exists) {Gray}$Package"
    }
}

function Install-PowerShellModule {
	param ([string]$Module, [string]$Version, [array]$AdditionalArgs)

	if (!(Get-InstalledModule -Name $Module -ErrorAction SilentlyContinue)) {
		$installModule = "Install-Module -Name $Module"
		if ($null -ne $Version) { $installModule += " -RequiredVersion $Version" }
		if ($AdditionalArgs.Count -ge 1) {
			$addArgs = $AdditionalArgs -join ' '
			$installModule = " $addArgs"
		}
		Invoke-Expression "$installModule"
	} else {
		Write-ColorText "{Blue}[module] {Magenta}pwsh: {Yellow}(exists) {Gray}$Module"
	}
}


function Install-OnlineFile {
	param ([string]$OutputDir, [string]$Url)
	Invoke-WebRequest -Uri $Url -OutFile $OutputDir
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
				Write-ColorText "`n✔️  Packages installed by {Green}$PackageSource {Gray}are exported at {Red}$((Resolve-Path $dest).Path)"
			}
			Start-Sleep -Seconds 1
		}
		"scoop" {
			if (!(Get-Command scoop -ErrorAction SilentlyContinue)) { return }
			scoop export -c > $dest
			if ($LASTEXITCODE -eq 0) {
				Write-ColorText "`n✔️  Packages installed by {Green}$PackageSource {Gray}are exported at {Red}$((Resolve-Path $dest).Path)"
			}
			Start-Sleep -Seconds 1
		}
		"modules" {
			Get-InstalledModule | Select-Object -Property Name, Version | ConvertTo-Json -Depth 100 | Out-File $dest
			if ($LASTEXITCODE -eq 0) {
				Write-ColorText "`n✔️  {Green}PowerShell Modules {Gray}installed are exported at {Red}$((Resolve-Path $dest).Path)"
			}
			Start-Sleep -Seconds 1
		}
	}
}

function New-SymbolicLinks {
	param (
		[string]$Source,
		[string]$Destination,
		[switch]$Recurse
	)

	Get-ChildItem $Source -Recurse:$Recurse | Where-Object { !$_.PSIsContainer } | ForEach-Object {
		$destinationPath = $_.FullName -replace [regex]::Escape($Source), $Destination
		if (!(Test-Path (Split-Path $destinationPath))) {
			New-Item (Split-Path $destinationPath) -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
		}
		New-Item -ItemType SymbolicLink -Path $destinationPath -Target $($_.FullName) -Force -ErrorAction SilentlyContinue | Out-Null
		Write-ColorText "{Blue}[symlink] {Green}$($_.FullName) {Yellow}--> {Gray}$destinationPath"
	}
}

########################################################################
###														MAIN SCRIPT 		  					 			 		 ###
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

Write-Progress -Completed; Clear-Host

Write-ColorText "`n✅ {Green}Internet Connection available.`n`n{DarkGray}Start running setup process..."
Start-Sleep -Seconds 3

# set current working directory location
$currentLocation = "$($(Get-Location).Path)"

Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

$i = 1


######################################################################
###													NERD FONTS														 ###
######################################################################
# install nerd fonts
Write-TitleBox -Title "Nerd Fonts Installation"
Write-ColorText "{Green}The following fonts are highly recommended:`n{DarkGray}(Please skip this step if you already installed Nerd Fonts)`n`n  {red}● 0xProto Nerd Font`n"

for ($count = 30; $count -ge 0; $count--) {
	Write-ColorText "`r{Magenta}Install Nerd Fonts now? [y/N]: {DarkGray}(Exit in {Blue}$count {DarkGray}seconds) {Gray}" -NoNewLine

	if ([System.Console]::KeyAvailable) {
		$key = [System.Console]::ReadKey($false)
		if ($key.Key -ne 'Y') {
			Write-ColorText "`r{DarkGray}Skipped installing Nerd Fonts...                                                                 "
			break
		} else {
			& ([scriptblock]::Create((Invoke-WebRequest 'https://to.loredo.me/Install-NerdFont.ps1'))) -Scope AllUsers -Confirm:$False
			break
		}
	}
	Start-Sleep -Seconds 1
}
Refresh ($i++)

Clear-Host



########################################################################
###													WINGET PACKAGES 			 									 ###
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
	Refresh ($i++)
}

########################################################################
###														SCOOP PACKAGES 	 							 				 ###
########################################################################
# Scoop Packages
Write-TitleBox -Title "Scoop Packages Installation"
$scoopItem = $json.installSource.scoop
$scoopBuckets = $scoopItem.bucketList
$scoopPkgs = $scoopItem.packageList
$scoopArgs = $scoopItem.additionalArgs
$scoopInstall = $scoopItem.autoInstall

if ($scoopInstall -eq $True) {
	if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
		# `scoop` is recommended to be installed from a non-administrative
		# PowerShell terminal. However, since we are in administrative shell,
		# it is required to invoke the installer with the `-RunAsAdmin` parameter.

		# Source: - https://github.com/ScoopInstaller/Install#for-admin
		Write-Verbose -Message "Installing scoop"
		Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
	}

	# Configure aria2
	if (!(Get-Command aria2c -ErrorAction SilentlyContinue)) { scoop install aria2 }
	if (!($(scoop config aria2-enabled) -eq $True)) { scoop config aria2-enabled true }
	if (!($(scoop config aria2-warning-enabled) -eq $False)) { scoop config aria2-warning-enabled false }

	# Create a scheduled task for aria2 so that it will always be active when we logon the machine
	# Idea is from: - https://gist.github.com/mikepruett3/7ca6518051383ee14f9cf8ae63ba18a7
	if (!(Get-ScheduledTaskInfo -TaskName "Aria2RPC" -ErrorAction Ignore)) {
		try {
			$scoopDir = (Get-Command scoop.ps1 -ErrorAction SilentlyContinue).Source | Split-Path | Split-Path
			$Action = New-ScheduledTaskAction -Execute "$scoopDir\apps\aria2\current\aria2c.exe" -Argument "--enable-rpc --rpc-listen-all" -WorkingDirectory "$Env:USERPROFILE\Downloads"
			$Trigger = New-ScheduledTaskTrigger -AtStartup
			$Principal = New-ScheduledTaskPrincipal -UserID "$Env:USERDOMAIN\$Env:USERNAME" -LogonType S4U
			$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
			Register-ScheduledTask -TaskName "Aria2RPC" -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings | Out-Null
		} catch {
			Write-Error "An error occurred: $_"
		}
	}

	# Add scoop buckets
	foreach ($bucket in $scoopBuckets) {
		$bucketName = $bucket.bucketName
		$bucketRepo = $bucket.bucketRepo
		if ($null -ne $bucketRepo) {
			Add-ScoopBucket -BucketName $bucketName -BucketRepo $bucketRepo
		} else {
			Add-ScoopBucket -BucketName $bucketName
		}
	}

	''

	# Install applications from scoop
	foreach ($pkg in $scoopPkgs) {
		$pkgName = $pkg.packageName
		$pkgScope = $pkg.packageScope
		if (($null -ne $pkgScope) -and ($pkgScope -eq "global")) { $Global = $True } else { $Global = $False }
		if ($null -ne $scoopArgs) {
			Install-ScoopApp -Package $pkgName -Global:$Global -AdditionalArgs $scoopArgs
		} else {
			Install-ScoopApp -Package $pkgName -Global:$Global
		}
	}
	Write-LockFile -PackageSource scoop -FileName scoopfile.json
	Refresh ($i++)
}

####################################################################
###															SYMLINKS 												 ###
####################################################################
# symlinks
Write-TitleBox -Title "Add symbolic links for dotfiles"
New-SymbolicLinks -Source "$PSScriptRoot\config\home" -Destination "$env:USERPROFILE" -Recurse
New-SymbolicLinks -Source "$PSScriptRoot\config\AppData" -Destination "$env:USERPROFILE\AppData" -Recurse
New-SymbolicLinks -Source "$PSScriptRoot\config\config" -Destination "$env:USERPROFILE\.config" -Recurse
Refresh ($i++)


##########################################################################
###													ENVIRONMENT VARIABLES											 ###
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
            & yasbc.exe enable-autostart --task -ErrorAction Stop
            Write-Host "✅ YASB autostart task created." -ForegroundColor Green
        } catch {
            Write-Error "Failed to enable YASB autostart: $_"
        }
    } else {
        Write-Host "✅ YASB autostart task already exists." -ForegroundColor Green
    }

    # 2. Start it for the current session if not running
    if (!(Get-Process -Name yasb -ErrorAction SilentlyContinue)) {
        Write-Host "Starting YASB for current session..."
        try { & yasbc.exe start } catch { Write-Error $_ }
    } else {
        Write-Host "✅ YASB is already running." -ForegroundColor Green
    }
} else {
    Write-Warning "Command not found: yasbc."
}

# --- KOMOREBI ---
if (Get-Command komorebic -ErrorAction SilentlyContinue) {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $regKeyName = "komorebi"
    
    # Get the full path to the executable
    $komorebiExePath = (Get-Command komorebic.exe).Source
    
    # This is the command that will be run at startup, hidden
    $startupCommand = "powershell.exe -WindowStyle Hidden -Command `"$komorebiExePath start --ahk`""

    # 1. Create the autostart registry key if it doesn't exist or is incorrect
    $currentRegValue = Get-ItemProperty -Path $regPath -Name $regKeyName -ErrorAction SilentlyContinue
    
    if ($null -eq $currentRegValue -or $currentRegValue.$regKeyName -ne $startupCommand) {
        Write-Host "Creating autostart registry key for Komorebi..."
        try {
            Set-ItemProperty -Path $regPath -Name $regKeyName -Value $startupCommand -Type String -Force -ErrorAction Stop
            Write-Host "✅ Komorebi autostart key created." -ForegroundColor Green
        } catch {
            Write-Error "Failed to create Komorebi autostart key: $_"
        }
    } else {
        Write-Host "✅ Komorebi autostart key already exists." -ForegroundColor Green
    }

    # 2. Start it for the current session if not running
    if (!(Get-Process -Name komorebi -ErrorAction SilentlyContinue)) {
        Write-Host "Starting Komorebi for current session..."
        try { 
            # Start the process using the same hidden window method
            Start-Process "powershell.exe" -ArgumentList "-WindowStyle Hidden -Command `"$komorebiExePath start --ahk`"" 
        } catch { Write-Error $_ }
    } else {
        Write-Host "✅ Komorebi is already running." -ForegroundColor Green
    }
} else {
    Write-Warning "Command not found: komorebic."
}


######################################################################
###													END SCRIPT														 ###
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

Write-ColorText "`n`n{Grey}For next steps, please visit: {Blue}https://github.com/blue-pho3nix/blue-windots/tree/Huntress`n"

