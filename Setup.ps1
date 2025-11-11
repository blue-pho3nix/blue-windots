
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
    param (
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [string]$BorderChar = "█", # Using a solid block character for a modern look
        [int]$HorizontalPadding = 5,
        [int]$VerticalPadding = 1,
        [ConsoleColor]$BorderColor = 'Green', # Added color parameter
        [ConsoleColor]$TitleColor = 'Yellow'
    )

    # Input validation
    if ($Title -eq "") {
        Write-Error "Title cannot be empty."
        return
    }
    if ($HorizontalPadding -lt 1 -or $VerticalPadding -lt 0) {
        Write-Error "Padding values must be non-negative."
        return
    }

    $TitleText = $Title.ToUpper()
    $TitleLength = $TitleText.Length

    # Calculate the total width of the box
    # Total width = Title length + Left padding + Right padding + 2 (for the border chars)
    $BoxWidth = $TitleLength + ($HorizontalPadding * 2) + 2

    # Title Line Construction
    # Smart Padding: If HorizontalPadding is odd, the extra space goes to the right side
    $LeftPaddingSpaces = " " * $HorizontalPadding
    $RightPaddingSpaces = " " * $HorizontalPadding

    $TitleLine = "$BorderChar$LeftPaddingSpaces$TitleText$RightPaddingSpaces$BorderChar"

    # Border and Vertical Padding Line Construction
    $BorderLine = $BorderChar * $BoxWidth
    
    # Vertical Padding Line: BorderChar + spaces + BorderChar
    $InternalSpaces = " " * ($BoxWidth - 2)
    $PaddingLine = "$BorderChar$InternalSpaces$BorderChar"

    # Output
    
    # Top Border
    Write-Host ""
    Write-Host $BorderLine -ForegroundColor $BorderColor

    # Top Vertical Padding
    1..$VerticalPadding | ForEach-Object {
        Write-Host $PaddingLine -ForegroundColor $BorderColor
    }

    # Title Line
    Write-Host -NoNewline "$BorderChar" -ForegroundColor $BorderColor
    Write-Host -NoNewline "$LeftPaddingSpaces" -ForegroundColor $TitleColor
    Write-Host -NoNewline "$TitleText" -ForegroundColor $TitleColor
    Write-Host -NoNewline "$RightPaddingSpaces" -ForegroundColor $TitleColor
    Write-Host "$BorderChar" -ForegroundColor $BorderColor # Ends the TitleLine with a newline

    # Bottom Vertical Padding
    1..$VerticalPadding | ForEach-Object {
        Write-Host $PaddingLine -ForegroundColor $BorderColor
    }

    # Bottom Border
    Write-Host $BorderLine -ForegroundColor $BorderColor
    Write-Host ""
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

    Write-ColorText "{Cyan}Checking if package '$PackageID' is already installed..."

    # Define a variable to track existence
    $_packageExists = $false

    # Run winget list and check exit code
    Write-ColorText "{Gray}Running: winget list --exact --id $PackageID"
    $listProcess = Start-Process winget -ArgumentList "list", "--exact", "--id", $PackageID -Wait -PassThru -NoNewWindow -ErrorAction Stop
    if ($listProcess.ExitCode -ne 0) {
        # It failed OR the package wasn't found (ExitCode 1 typically means not found)
        Write-ColorText "{Yellow}Package '$PackageID' not found or 'winget list' failed. Proceeding with install attempt..."
        $_packageExists = $false
    }
    else {
        # Package exists
        Write-ColorText "{Green}Package '$PackageID' found."
        $_packageExists = $true
    }

    # Proceed with installation only if the package does not exist
    if ($_packageExists -eq $false) {
        Write-ColorText "{Yellow}Preparing installation command for '$PackageID'..."

        # Build arguments for Start-Process
        $wingetProcessArgs = @("install", "--id", $PackageID)

        # Add arguments from AppList.json
        if ($AdditionalArgs.Count -ge 1) {
            $wingetProcessArgs += $AdditionalArgs
        }

        # Add source argument
        if ($Source -eq "msstore") {
            # Keep the package agreement here as it's specific to msstore
            $wingetProcessArgs += "--source", "msstore", "--accept-package-agreements" 
            Write-Verbose "Adding --accept-package-agreements for $PackageID (MS Store)"
        }
        else {
            # Only add the source name for the winget repository
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

        $commandStringForDisplay = "winget $($wingetProcessArgs -join ' ')"
        Write-ColorText "{Magenta}Executing: $commandStringForDisplay"
        try {
            # Use Start-Process -Wait instead of Invoke-Expression
            $process = Start-Process winget -ArgumentList $wingetProcessArgs -Wait -PassThru -ErrorAction Stop -Verbose:$false

            # Check the Exit Code after waiting
            if ($process.ExitCode -eq 0) {
                Write-ColorText "{Blue}[package] {Magenta}winget: {Green}(success) {Gray}$PackageID"
            }
            else {
                Write-ColorText "{Blue}[package] {Magenta}winget: {Red}(FAILURE - Exit Code $($process.ExitCode)) {Gray}$PackageID"
                Write-Error "Winget failed for $PackageID. Exit Code: $($process.ExitCode). Run the script again..."
                exit 1 
            }
        }
        catch {
            # Catch errors if Start-Process itself fails (e.g., winget not found)
            Write-Error "Failed to start winget process for $PackageID`: $_"
            Write-ColorText "{Blue}[package] {Magenta}winget: {Red}(failed - Exception executing winget) {Gray}$PackageID"
        }

    }
    else {
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

    Write-ColorText "{DarkGray}Environment variables refreshed for the current session."
}





########################################################################
###                      Main Script                                 ###
########################################################################

# If not internet connection, then exit
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
    # Check 1: Does the 'winget' command exist?
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-ColorText "{Green}WinGet is already installed and available. Skipping update/install."
        # Exit the WinGet setup block entirely since it's already there
        # We still run Refresh later, but no installation is needed.
    }
    else {
        Write-ColorText "Installing WinGet..."
        Write-Host "WinGet not found. Proceeding with installation/update..."
        
        # Define file paths and URI
        $wingetUri = "https://aka.ms/getwinget"
        $wingetBundle = "$env:TEMP\AppInstaller.appxbundle"

        try {
            # Download the latest bundle 
            Write-Host "Downloading latest App Installer bundle..."
            Invoke-WebRequest -Uri $wingetUri -OutFile $wingetBundle -UseBasicParsing -ErrorAction Stop

            # Unblock the file
            Write-Host "Unblocking downloaded file security tag..."
            Unblock-File -Path $wingetBundle -ErrorAction SilentlyContinue

            # Check and install VCLibs Dependency 
            Write-Host "Ensuring Microsoft VCLibs runtime dependency is installed..."
            $VCLibsPackageName = "Microsoft.VCLibs.140.00"
            
            if (-not (Get-AppxPackage -Name $VCLibsPackageName -AllUsers -ErrorAction SilentlyContinue)) {
                Write-Warning "VCLibs Runtime not found. Attempting to install required dependency..."
                $VCLibsUri = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
                $VCLibsBundle = "$env:TEMP\VCLibs.appx"
                
                Invoke-WebRequest -Uri $VCLibsUri -OutFile $VCLibsBundle -UseBasicParsing -ErrorAction Stop
                Unblock-File -Path $VCLibsBundle -ErrorAction SilentlyContinue
                
                Add-AppxPackage -Path $VCLibsBundle -ErrorAction Stop
                Write-Host "VCLibs Runtime installed successfully."
            }
            
            # Apply the App Installer bundle 
            Write-Host "Installing App Installer..."
            Add-AppxPackage -Path $wingetBundle -ErrorAction Stop
            
            Write-ColorText "{Green}WinGet (App Installer) installed successfully."
            
        }
        catch {
            # Failure and Exit
            Write-Error "Failed to install App Installer (WinGet). Package installation cannot proceed."
            Write-Host "Error Details: $($_.Exception.Message)"
            Write-Host "Exiting script due to WinGet failure."
            exit 1
        }
    }

    
    # Add a delay to allow the App Execution Alias to stabilize
    Write-Host "Waiting a few seconds for WinGet background services to start..."
    Start-Sleep -Seconds 5 

    # The WinGet client may be too new and needs a source refresh/init 
    Write-Host "Forcing an initial WinGet source refresh..."
    # Use an explicit reset/update combination for robustness
    winget source reset --force
    winget source update

    # Download packages from WinGet
    foreach ($pkg in $wingetPkgs) {
        $pkgId = $pkg.packageId
        $pkgSource = $pkg.packageSource
        if ($null -ne $pkgSource) {
            Install-WinGetApp -PackageID $pkgId -AdditionalArgs $wingetArgs -Source $pkgSource
        }
        else {
            Install-WinGetApp -PackageID $pkgId -AdditionalArgs $wingetArgs
        }
    }
}

Refresh ($i++)


########################################################################
###                     Nerd Fonts                                   ###
########################################################################

Write-TitleBox -Title "Nerd Fonts Installation"

# Check if Oh My Posh is installed and available in the PATH
$omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue

if ($null -ne $omp) {
    Write-ColorText "{Green}Found 'oh-my-posh'. Attempting to install 'JetBrainsMono'..."
    Write-ColorText "{Gray}(This may take a moment...)"

    try {
        # Execute the oh-my-posh font installer for 0xProto
        # We add -ErrorAction Stop to catch errors in the 'catch' block
        oh-my-posh font install JetBrainsMono
        
        Write-ColorText "`n{Green}Successfully installed 'JetBrainsMono'."
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
###                        Windhawk Setup                            ###
########################################################################
Write-TitleBox -Title "Windhawk Mod Setup"

$BaseRegistryPath = 'HKLM:\SOFTWARE\Windhawk\Engine\Mods\'
$SilentInstallArgs = "/S" # Standard silent switch for many installers
$EnableValue = 0 # 0 means ENABLED for the 'Disabled' registry key

# In the Windhawk Setup section (around line 528 in your full script)
$ModConfigurations = @(
    # UXTheme Hook Configuration
    @{ Name = 'UXTheme Hook'; Key = 'uxtheme-hook'; Settings = @{} },
    
    # Control Panel Color Fix Configuration
    @{ Name = 'Control Panel Color Fix'; Key = 'control-panel-color-fix'; Settings = @{} },

    # Resource Redirect Configuration (Nord Papirus Icon Theme)
    @{ Name = 'Resource Redirect'; Key = 'icon-resource-redirect'; 
        Settings = @{ 'iconTheme' = 'Nord Papirus|themes/icons/niivu/Nord%20Papirus.zip';
            'ClearCacheOnUpdate'  = 0 
        }
    },
    
    # Windows 11 Taskbar Styler Configuration (Hide Taskbar)
    @{ 
        Name     = 'Windows 11 Taskbar Styler'; 
        Key      = 'windows-11-taskbar-styler'; 
        Settings = @{ 
            'theme'                            = 'SimplyTransparent';
            'controlStyles[0].target'          = 'Taskbar.TaskListButtonPanel';
            'controlStyles[0].styles[0]'       = 'Visibility=Collapsed';
            'styleConstants[0]'                = '';
            'resourceVariables[0].variableKey' = '';
            'resourceVariables[0].value'       = '';
            'controlStyles[1].target'          = 'Taskbar.TaskListLabeledButtonPanel';
            'controlStyles[1].styles[0]'       = 'Visibility=Collapsed';
            'controlStyles[2].target'          = 'SystemTray.OmniButton';
            'controlStyles[2].styles[0]'       = 'Visibility=Collapsed';
        } 
    },
    
    # Windows 11 File Explorer Styler Configuration (Matter Theme)
    @{ Name = 'Windows 11 File Explorer Styler'; Key = 'windows-11-file-explorer-styler'; 
        Settings = @{ 'Theme' = 'Matter' } 
    },
    
    # Windows 11 Notification Center Styler Configuration (WindowGlass Theme)
    @{ Name = 'Windows 11 Notification Center Styler'; Key = 'windows-11-notification-center-styler'; 
        Settings = @{ 'Theme' = 'WindowGlass' } 
    },

    # Windows 11 Start Menu Styler Configuration (WindowGlass Theme)
    @{ Name = 'Windows 11 Start Menu Styler'; Key = 'windows-11-start-menu-styler'; 
        Settings = @{ 'Theme' = 'WindowGlass' } 
    }
)


# Verify all required mods are installed 
Write-ColorText "{Yellow}`nChecking Required Windhawk Mods Installation Status"

# Array to store names of missing mods
$MissingMods = @()

foreach ($Mod in $ModConfigurations) {
    $ModKey = $Mod.Key
    $ModName = $Mod.Name
    $ModRegistryPath = $BaseRegistryPath + $ModKey

    if (-not (Test-Path $ModRegistryPath)) {
        Write-ColorText "{Red}  [MISSING] '$ModName' ($ModKey)"
        $MissingMods += $ModName
    }
    else {
        Write-ColorText "{Green}  [OK] '$ModName' is installed."
    }
}

# If there are missing mods, terminate the script
if ($MissingMods.Count -gt 0) {
    Write-ColorText "{Red}`nERROR: The following required Windhawk mods are not installed:"
    $MissingMods | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    Write-ColorText "{Red}`nPlease install these mods via the Windhawk app and re-run the script."
    exit 1
}

Write-ColorText "{Green}`nAll required Windhawk mods are present."
Start-Sleep -Seconds 2

# Configure mods via registry including enabling
Write-ColorText "{Green}`n Configuring and Enabling Installed Mods via Registry"

foreach ($Mod in $ModConfigurations) {
    $ModKey = $Mod.Key
    $ModName = $Mod.Name
    $ModSettings = $Mod.Settings
    $ModRegistryPath = $BaseRegistryPath + $ModKey
    $SettingsPath = $ModRegistryPath + '\Settings'

    Write-Host "`n- Configuring '$ModName' ($ModKey)..."

    # Check if the mod's main key exists (i.e., the mod is installed)
    if (-not (Test-Path $ModRegistryPath)) {
        Write-ColorText "{Red}  [SKIPPED] Mod key not found. Please ensure '$ModName' is installed in Windhawk."
        continue
    }

    # Reports current status before enforcement
    $CurrentDisabled = (Get-ItemProperty -Path $ModRegistryPath -Name 'Disabled' -ErrorAction SilentlyContinue).Disabled

    if ($CurrentDisabled -eq 1) {
        Write-ColorText "{Red}  - Status: Currently disabled."
        Write-ColorText "{Red}  - Configuration halted for '$ModName'. Please enable it and restart the script."
        exit 1
    }

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
        Write-ColorText "{Green}  - Set $SettingName to '$SettingValue'"
    }
    # Force Windhawk to reload settings by updating SettingsChangeTime
    $CurrentTicks = [System.DateTime]::UtcNow.Ticks
    Set-ItemProperty -Path $ModRegistryPath -Name 'SettingsChangeTime' -Value $CurrentTicks -Type QWord -Force
}

Write-Host "Waiting 10 seconds for the Windhawk to finish configurations..."
Start-Sleep -Seconds 10 

Refresh ($i++)


########################################################################
###                         Hide Search Bar                          ###
########################################################################

Write-TitleBox -Title "Hide Taskbar Search Bar"

Write-ColorText "{Green}`n Hiding the taskbar search bar..."

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0


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

}
catch {
    Write-Error "Failed to hide system tray clock: $($_.Exception.Message)"
}

Refresh ($i++)




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
}
else {
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
}
else {
    Write-ColorText "{Red}Warning: Source directory not found for themes: {Gray}$sourceTheme"
}

Start-Sleep -Seconds 10


########################################################################
###                   Theme Setup                                    ###
########################################################################

Write-TitleBox -Title "Theme Setup"
Write-ColorText "{yellow}Applying Theme..."
Start-Sleep -Seconds 2

# Define Theme File Path. Ensure the file extension is exact.
$themeFile = "C:\Windows\Resources\Themes\Nord PAC - Polar Dark.theme"

Write-Host "Unblocking theme file security tag..."
# Unblock-File removes the 'Mark-of-the-Web' security tag
Unblock-File -Path $themeFile -ErrorAction SilentlyContinue

Write-Host "Applying theme via Control Panel command..."

# Use control.exe to apply the theme
# The command structure is: control /name Microsoft.Personalization /page pageTheme /action selectTheme <Theme Name>
# However, the simplest way is to directly launch the file via control.exe
# We use -PassThru to suppress unnecessary output and -Wait to ensure execution completes
$null = Start-Process -FilePath control.exe -ArgumentList "color" -PassThru -Wait
Start-Process -FilePath $themeFile -WindowStyle Hidden -ErrorAction SilentlyContinue

# Alternative, more robust method (uncomment if the above fails):
# Note: This is usually for .themepack files, but sometimes works on .theme files in the system folder.
# $null = Start-Process -FilePath $themeFile -PassThru -Wait

# Give the theme process a moment to execute
Write-Host "Waiting 3 seconds for the theme to start applying..."
Start-Sleep -Seconds 3

# No need to refresh environment variables again if the theme applied.
# Environment variables refreshed for the current session.

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
}
else {
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
            }
            catch {
                Write-Error -ErrorAction Stop "An error occurred: $_"
            }
        }
        else {
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

Write-ColorText "{Cyan}Configuring Starship for PowerShell..."

# The line to add
$initLine = 'Invoke-Expression (&starship init powershell)'

# Get current user's PowerShell profile path
$profilePath = $PROFILE

# Make sure the profile file exists
if (!(Test-Path -Path $profilePath)) {
    Write-ColorText "{Yellow}Profile not found, creating: $profilePath"
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# Add Starship initialization (avoid duplicates)
if (-not (Select-String -Path $profilePath -Pattern 'starship init powershell' -Quiet)) {
    Add-Content -Path $profilePath -Value "`n# >>> Starship Initialization >>>`n$initLine`n# <<< Starship Initialization <<<`n"
    Write-ColorText "{Green}Starship initialization added to: $profilePath"
}
else {
    Write-ColorText "{Yellow}Starship already configured in: $profilePath"
}

Write-ColorText "{Cyan}Starship setup complete."


########################################################################
###                       Start Komorebi + Yasb                      ###
########################################################################

Write-TitleBox "Komorebi & Yasb Engines"

# YASB
# Check if the yasbc command is available
if (Get-Command yasbc -ErrorAction SilentlyContinue) {
    Write-Host "Creating autostart task for yasb..."
    $TaskName = "YASB Reborn"
    $TaskPath = "\" 
    
    try {
        # Remove the potentially corrupted existing task.
        Write-Host "Cleaning up existing task before re-registration..."
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue 

        # The "Run As" Group for interactive sessions
        $Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Limited
   
        # Define the trigger with the delay using the dedicated cmdlet parameter (most compatible)
        $DelayTimeSpan = New-TimeSpan -Seconds 30
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay $DelayTimeSpan
        Write-Host "30-second delay set on the 'At log on' trigger."
    
        # Define the command that yasbc would run
        $Action = New-ScheduledTaskAction -Execute "yasb.exe"

        # Register/create the task
        Register-ScheduledTask -TaskName $TaskName `
            -TaskPath $TaskPath `
            -Principal $Principal `
            -Action $Action `
            -Trigger $Trigger `
            
        Write-ColorText "{Green}Scheduled Task '$TaskName' successfully created."
    }
    catch {
        Write-Error "Failed to configure YASB autostart: $($_.Exception.Message)"
    }
}
else {
    Write-Warning "komorebic command not found. Please install komorebi"
}

# KOMOREBI 
# Check if 'komorebic' command is available first
if (Get-Command komorebic -ErrorAction SilentlyContinue) {
    Write-Host "Creating autostart task for Komorebi..."
    try {
        komorebic enable-autostart --whkd
        Write-Host "Waiting 10 seconds for Komorebi..."
        Start-Sleep -Seconds 10
        Write-ColorText "{Green}Komorerbi autostart successfully started."
    }
    catch {
        Write-Error "Failed to enable Komorebi autostart: $_"
    } 
}
else {
    Write-Warning "komorebic command not found. Please install komorebi"
} 



########################################################################
###                         End Script                               ###
########################################################################

Set-Location $currentLocation
Write-TitleBox -Title "SETUP COMPLETE! RESTART REQUIRED."
