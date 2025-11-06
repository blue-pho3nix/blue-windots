# Windots for Windows 11 😊
My semi-automated [Komorebi](https://github.com/LGUG2Z/Komorebi) + [yasb](https://github.com/amnweb/yasb) setup.



## Hotkeys
> [!NOTE]
> Feel free to add more hot keys to `C:\Users\<your_username>\.config\whkdrc` after install. 

<details closed>
  <summary>View the cool hotkeys 🔥</summary>

| Shortcut                      | Action                                 |
| ----------------------------- | -------------------------------------- |
| `alt` + `r`                   | Reload WHKD configuration              |
| `alt` + `q`                   | Close window                           |
| `alt` + `m`                   | Minimize window                        |
| `alt` + `left`                | Focus window to the left               |
| `alt` + `right`               | Focus window to the right              |
| `alt` + `down`                | Focus window below                     |
| `alt` + `up`                  | Focus window above                     |
| `alt` + `oem_plus`            | Resize window horizontally (increase)  |
| `alt` + `oem_minus`           | Resize window horizontally (decrease)  |
| `alt` + `shift` + `oem_plus`  | Resize window vertically (increase)    |
| `alt` + `shift` + `oem_minus` | Resize window vertically (decrease)    |
| `alt` + `t`                   | Toggle floating window                 |
| `alt` + `shift` + `f`         | Toggle monocle mode                    |
| `alt` + `shift` + `left`      | Move window left                       |
| `alt` + `shift` + `right`     | Move window right                      |
| `alt` + `shift` + `down`      | Move window down                       |
| `alt` + `shift` + `up`        | Move window up                         |
| `alt` + `space`               | Promote window                         |
| `alt` + `1`                   | Focus workspace 1                      |
| `alt` + `2`                   | Focus workspace 2                      |
| `alt` + `3`                   | Focus workspace 3                      |
| `alt` + `shift` + `1`         | Move window to workspace 1             |
| `alt` + `shift` + `2`         | Move window to workspace 2             |
| `alt` + `shift` + `3`         | Move window to workspace 3             |
| `alt` + `w`                   | Focus or open Chrome                   |
| `alt` + `return`              | Open Windows Terminal                  |
| `alt` + `shift` + `return`    | Open Windows Terminal as Administrator |
| `alt` + `c`                   | Open Command Prompt                    |
| `alt` + `shift` + `c`         | Open Command Prompt as Administrator   |
| `alt` + `f`                   | Open File Explorer                     |
| `alt` + `0`                   | Restart computer                       |

</details>



---

## Optional Pre-Install

### Create a [restore point](https://support.microsoft.com/en-us/windows/system-protection-e9126e6e-fa64-4f5f-874d-9db90e57645a)
> [!IMPORTANT]  
> Optional, but recommended.

### If You Want to Change the Desktop Images
- You can preview the current desktop images [here](https://github.com/blue-pho3nix/blue-windots/tree/main/config/theme/One%20Dark%20Pro/Wallpapers) before installing...
- You can always edit them in your Git clone if you want the diff background images to be automatically set to slideshow during installation.

---

## Required Pre-Install

> [!TIP]
> If You have **fewer/more than 5 monitors**, change the `blue-windots\config\home\Komorebi.json` to meet your needs.

### 1. Install [Windhawk](https://windhawk.net/) and Mods
> [!NOTE]
> I want to script the entire install for Windhawk, but Windhawk is not currently set up to do so... <br>
> At this point, you can manually install the mods, and the setup for each mod will be in the script below. <br><br>
> Also, you don't need `winlogon.exe` and `logonui.exe`  in UXTheme hook's advanced settings. <br>
> The theme doesn't really have settings for the login/lock screen.

#### Install the following mods under `Explore`
- Control Panel Color Fix
- Resource Redirect
- Windows 11 File Explorer Styler
- Windows 11 Notification Center Styler
- Windows 11 Start Menu Styler
- Windows 11 Taskbar Styler
- UXTheme hook


![](https://github.com/user-attachments/assets/9006bdf4-dab3-41b7-95d5-9796e36aca2a)

### 2. Install [Windows Terminal](https://apps.microsoft.com/detail/9N0DX20HK701?hl=en-us&gl=US&ocid=pdpshare)

### 3. Install [Powershell 7](https://apps.microsoft.com/detail/9MZ1SNWT0N5D?hl=en-us&gl=US&ocid=pdpshare)

---

## What Does the Setup.ps1 Do?

<details closed>
  <summary> The script does the following 💙...</summary>
  
  **Installs:**
  - **[Winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/)** (This installs the applications)
  - **[Komorebi](https://github.com/LGUG2Z/komorebi)** (Windows tiling manager).
  - **[yasb](https://github.com/amnweb/yasb)** (Status bar at the top of the screen).
  - **[OhMyPosh](https://ohmyposh.dev/)** (Just installed to make nerd font installation easier).  
  - **[0xProto Nerd Font](https://www.programmingfonts.org/#oxproto)** (Used in the terminal and yasb).
  - **[Git](https://git-scm.com/install/windows)** (Used by Scoop)
  - **[Clink](https://chrisant996.github.io/clink/clink.html)** (Makes it easy to use Starship in Command Prompt)
  - **[Starship](https://starship.rs/)** (Makes your terminal pretty)
 
  **Sets up:**
  - **The [theme](https://www.deviantart.com/niivu/art/One-Dark-Pro-for-Windows-11-930312689)** (Applies a theme `One Dark Pro (Night) - PAC.theme`...this give you pacman icons in File Explorer...).
  - **Windhawk** (Configures mods).
  - **Environment Variables** (Sets custom environment variables defined in `appList.json`).
  - **Starship** (Adds the initialization line to the user's PowerShell profile).
  - **Komorebi** (Enables autostart).
  - **YASB** (Enables autostart).
  - **Clink** (Disables the Clink banner/logo).
  
  **Other:**
  - **Copies over config files** (Copies dotfiles from `config\home` to `$env:USERPROFILE`).
  - **Copies over theme assets** (Copies files from `config\theme` to `C:\Windows\Resources\Themes`).
  - **Toggles off clock in taskbar** (Hides the taskbar clock).
  - **Sets the Long Paths Enabled registry key** (For Komorebi).
</details>

--- 

## Install Instructions

#### 1. Open Powershell 7 as `Administrator`.
#### 2. Clone the repo using GitHub Desktop, `git`, or download as a .zip.

```
git clone https://github.com/blue-pho3nix/blue-windots.git
```
#### 3. `cd` into the `blue-dots` directory.
#### 4. Run `Setup.ps1`.
> [!NOTE]
> 1. You may need to accept msstore agreements. The default msstore source includes packages in the Microsoft Store.<br>
> 2. You don't need to refresh cache for Windhawk Resource Redirect. <br>
> 3. After the install, make sure to reboot.
```
.\Setup.ps1
```

---

## Post Install Fun

### Let's say you want to edit you Komorebi config file after install.
<details closed>
  <summary>Here's how you can do it. 🎉</summary>

1. Edit and save `C:\Users\<your_username>\Komorebi.json`   
2. Open a regular powershell window (`win + enter`).
3. Stop and start Komorebi or reload the configuration.
> Make sure to always use `--ahk` to keep the autohotkeys working. <br>

```
Komorebic stop --ahk
```
```
Komorebic start --ahk
```
or
```
Komorebic reload-configuration
```
4. Reload scripts in AutoHotKey (right click AutoHotKey and click `Reload Scripts`).

![](https://github.com/user-attachments/assets/62340ca3-c9a4-4d4b-b6ad-102978f32fa5)

</details>

---

## Got Questions, Issues, or Suggestions?
Ping me in #rice on [Discord](https://discord.gg/TujAjYXJjr) (Blue Pho3nix).
