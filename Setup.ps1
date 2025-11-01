
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


########################################################################
###                     HELPER FUNCTIONS                             ###
########################################################################
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
        if ($i % 2 -eq 0) { Write-Host $_ -NoNewline }
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
        [ValidateSet('winget')]
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
    }
}


########################################################################
###                      Main Script                                 ###
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
###                Winget Packages Installation                      ###
########################################################################
# Enable support for long paths before installing Komorebi
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

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
###          Komorebi AutoHotkey PATH Configuration                  ###
########################################################################

Write-TitleBox -Title "Komorebi AHK Path Setup"

# Set the KOMOREBI_AHK_EXE environment variable permanently for the current user.
Write-Host "Setting KOMOREBI_AHK_EXE environment variable permanently..." -ForegroundColor Cyan
[System.Environment]::SetEnvironmentVariable(
    'KOMOREBI_AHK_EXE', 
    "$Env:USERPROFILE\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey64.exe", 
    'User'
)
Write-Host "Path saved to registry for future sessions." -ForegroundColor Green

# Force the current script session to  reload all User environment variables, 
# including the KOMOREBI_AHK_EXE variable we just set.
Write-Host "Applying environment changes to current script session." -ForegroundColor Yellow
Refresh ($i++)


########################################################################
###                     Nerd Fonts                                   ###
########################################################################

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



########################################################################
###            Toggle OFF Time and Date in System Tray               ###
########################################################################
Write-TitleBox -Title "Toggle OFF Time/Date in System Tray"

# Path to the Advanced Explorer key
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" 
$regValueName = "ShowSystrayDateTimeValueName"

Write-ColorText "{Cyan}Setting registry key to hide clock in system tray..."

try {
    # Setting the value to 0 (False) hides the clock.
    # Note: If this key does not exist, the system might default to showing the clock.
    # We use -Force to create it if it doesn't exist.
    Set-ItemProperty -Path $regPath -Name $regValueName -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-ColorText "{Green}Clock is now hidden in the System Tray."
    
    # Restart Windows Explorer to apply the change immediately
    Write-ColorText "{Green}Restarting Windows Explorer..."
    taskkill /f /im explorer.exe; start explorer

} catch {
    Write-Error "Failed to hide system tray clock: $($_.Exception.Message)"
}


########################################################################
###                          Copy Files                              ###
########################################################################

Write-TitleBox -Title "Copy Dotfiles and Theme Assets"

# Copy dotfiles to user profile (Original)
$sourceHome = "$PSScriptRoot\config\home"
$destinationHome = "$env:USERPROFILE"

Write-ColorText "{Blue}[copy] {Green}Copying dotfiles from $sourceHome... {Yellow}to {Gray}$destinationHome"

if (Test-Path $sourceHome) {
    # The \* copies the *contents* of the source folder
    Copy-Item -Path "$sourceHome\*" -Destination $destinationHome -Recurse -Force -ErrorAction SilentlyContinue
    Write-ColorText "{Green}Dotfiles copied successfully."
} else {
    Write-ColorText "{Red}Warning: Source directory not found for dotfiles: {Gray}$sourceHome"
}


# Copy Theme Files to Windows Resources
$sourceTheme = "$PSScriptRoot\config\theme\"
$destinationTheme = "C:\Windows\Resources\Themes\"

Write-ColorText "{Blue}[copy] {Green}Copying theme files from $sourceTheme... {Yellow}to {Gray}$destinationTheme"

if (Test-Path $sourceTheme) {
    # Copying theme files and supporting folders
    Copy-Item -Path "$sourceTheme\*" -Destination $destinationTheme -Recurse -Force -ErrorAction SilentlyContinue
    Write-ColorText "{Green}Theme files copied successfully."
} else {
    Write-ColorText "{Red}Warning: Source directory not found for themes: {Gray}$sourceTheme"
}

Start-Sleep -Seconds 5



########################################################################
###                        Windhawk Setup                            ###
########################################################################
Write-TitleBox -Title "Windhawk Mod Setup"

$BaseRegistryPath = 'HKLM:\SOFTWARE\Windhawk\Engine\Mods\'
$SilentInstallArgs = "/S" # Standard silent switch for many installers
$EnableValue = 0 # 0 means ENABLED for the 'Disabled' registry key

# In the Windhawk Setup section (around line 528 in your full script)
$ModConfigurations = @(
    # Control Panel Color Fix Configuration
    @{ Name = 'Control Panel Color Fix'; Key = 'control-panel-color-fix'; Settings = @{} },
    
    # Resource Redirect Configuration (Bonny Icon Theme)
    @{ Name = 'Resource Redirect'; Key = 'icon-resource-redirect'; 
       Settings = @{ 'IconTheme' = 'Bonny' } },
    
    # Windows 11 Taskbar Styler Configuration (Matter Theme)
    @{ Name = 'Windows 11 Taskbar Styler'; Key = 'windows-11-taskbar-styler'; 
       Settings = @{ 'Theme' = 'Matter' } },
    
    # Windows 11 File Explorer Styler Configuration (Matter Theme)
    @{ Name = 'Windows 11 File Explorer Styler'; Key = 'windows-11-file-explorer-styler'; 
       Settings = @{ 'Theme' = 'Matter' } },
    
    # Windows 11 Notification Center Styler Configuration (Matter Theme)
    @{ Name = 'Windows 11 Notification Center Styler'; Key = 'windows-11-notification-center-styler'; 
       Settings = @{ 'Theme' = 'Matter' } },
    
    # Windows 11 Start Menu Styler Configuration (Oversimplified$Accentuated Theme)
    @{ Name = 'Windows 11 Start Menu Styler'; Key = 'windows-11-start-menu-styler'; 
       Settings = @{ 'Theme' = 'Oversimplified$Accentuated'; 'DisableNewLayout' = 1 } }
)


# Configure mods via registry including enabling

Write-Host "`n--- 2. Configuring and Enabling Installed Mods via Registry ---" -ForegroundColor Green
Write-Host "NOTE: The mods MUST be installed via the Windhawk app first for these settings to apply correctly."

foreach ($Mod in $ModConfigurations) {
    $ModKey = $Mod.Key
    $ModName = $Mod.Name
    $ModSettings = $Mod.Settings
    $ModRegistryPath = $BaseRegistryPath + $ModKey
    $SettingsPath = $ModRegistryPath + '\Settings'

    Write-Host "`n- Configuring '$ModName' ($ModKey)..."

    # Check if the mod's main key exists (i.e., the mod is installed)
    if (-not (Test-Path $ModRegistryPath)) {
        Write-Host "  [SKIPPED] Mod key not found. Please ensure '$ModName' is installed in Windhawk." -ForegroundColor Red
        continue
    }

    # Enable the mod
    Set-ItemProperty -Path $ModRegistryPath -Name 'Disabled' -Value $EnableValue -Type DWord -Force
    Write-Host "  - Set 'Disabled' to 0 (Mod Enabled)."

    # Ensure the Settings key exists
    if (-not (Test-Path $SettingsPath)) {
        New-Item -Path $SettingsPath -Force | Out-Null
        Write-Host "  - Created Settings key for mod."
    }

    # Set the custom settings
    foreach ($SettingName in $ModSettings.Keys) {
        $SettingValue = $ModSettings[$SettingName]
        $Type = [Microsoft.Win32.RegistryValueKind]::String
        
        if ($SettingValue -is [int]) {
            $Type = [Microsoft.Win32.RegistryValueKind]::DWord
        }
        
        Set-ItemProperty -Path $SettingsPath -Name $SettingName -Value $SettingValue -Type $Type -Force
        Write-Host "  - Set $SettingName ($Type) to '$SettingValue'"
    }

    # Force Windhawk to reload settings by updating SettingsChangeTime
    $CurrentTicks = [System.DateTime]::UtcNow.Ticks
    Set-ItemProperty -Path $ModRegistryPath -Name 'SettingsChangeTime' -Value $CurrentTicks -Type QWord -Force
    Write-Host "  - Updated SettingsChangeTime to trigger mod reload."
}

Write-Host "All specified Winhawk mods have been **Enabled** and **configured**."
Write-ColorText "{yellow}Reopen File Explorer to see the changes..."

Refresh ($i++)


########################################################################
###                          Theme Setup                             ###
########################################################################

Write-TitleBox -Title "Theme Setup"
Write-ColorText "{yellow}The Screen may flash."
Write-ColorText "{yellow}This may take some time..."
Start-Sleep -Seconds 2

# Define Theme File Path 
$themeFile = "C:\Windows\Resources\Themes\One Dark Pro (Night) - PAC.theme"

Write-Host "1. Unblocking theme file security tag..."
# Unblock-File removes the 'Mark-of-the-Web' security tag
Unblock-File -Path $themeFile

Write-Host "2. Silently applying theme..."
# Launch the theme application process silently, which should now run without a prompt
Start-Process -FilePath $themeFile -WindowStyle Hidden -Wait

Write-Host "3. Restarting Windows Explorer to reload theme..."
taskkill /f /im explorer.exe; Start-Process explorer.exe

Refresh ($i++)



########################################################################
###                        Clink Configuration                       ###
########################################################################

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


########################################################################
###                       Environment Variables                      ###
########################################################################

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


########################################################################
###                         Starship Setup                           ###
########################################################################

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

Write-Host "Starship setup complete." -ForegroundColor Cyan


########################################################################
###                       Start Komorebi + Yasb                      ###
########################################################################

Write-TitleBox "Komorebi & Yasb Engines"

# YASB
# Check if the yasbc command is available
if (Get-Command yasbc -ErrorAction SilentlyContinue) {

    # Start it for the current session if it is not running
    if (!(Get-Process -Name yasb -ErrorAction SilentlyContinue)) {
        Write-Host "Starting YASB for current session..."
        try { yasbc start } catch { Write-Error "Failed to start YASB for current session: $_" }
    } else {
        Write-Host "YASB is already running." -ForegroundColor Green
    }
    
    # 2. Check/Create autostart
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
    
} else {
    # This block is now only for when yasbc is genuinely NOT found (needs installation)
    Write-Warning "Command not found: yasbc. Please install YASB."
}

# KOMOREBI 
# Check if 'komorebic' command is available first
if (Get-Command komorebic -ErrorAction SilentlyContinue) {

    # Start Komorebi, but only if it's not already running
    if (!(Get-Process -Name komorebi -ErrorAction SilentlyContinue)) {
        komorebic start --ahk
    }

    # Set up autostart using the built-in command
    komorebic enable-autostart --ahk
    
} else {
    Write-Warning "komorebic command not found. Could not configure."
}


########################################################################
###                         End Script                               ###
########################################################################

Set-Location $currentLocation
Start-Sleep -Seconds 15

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

