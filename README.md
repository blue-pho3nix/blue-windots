# Nordish Windots for Windows 11 😊
My semi-automated [Komorebi](https://github.com/LGUG2Z/Komorebi) + [yasb](https://github.com/amnweb/yasb) setup.

<pics>

## Interesting [yasb Widgets](https://github.com/amnweb/yasb/wiki/(Widget)-Whkd)

<pics>

---

## Hotkeys
> [!NOTE]
> Feel free to add more hot keys to `C:\Users\<your_username>\.config\whkdrc` after install. 

<details closed>
  <summary>View the cool hotkeys 🔥</summary>

### Reload Komorebi Configuration
| Keys | Command |
|------|----------|
| `Alt + R` | `komorebic stop --whkd && komorebic start --whkd` |

---

### Close and Minimize Windows
| Keys | Command |
|------|----------|
| `Alt + Q` | `komorebic close` |
| `Alt + M` | `komorebic minimize` |

---

### Focus on Windows
| Keys | Command |
|------|----------|
| `Alt + ←` | `komorebic focus left` |
| `Alt + →` | `komorebic focus right` |
| `Alt + ↓` | `komorebic focus down` |
| `Alt + ↑` | `komorebic focus up` |

---

### Resize Windows
| Keys | Command |
|------|----------|
| `Alt + =` | `komorebic resize-axis horizontal increase` |
| `Alt + -` | `komorebic resize-axis horizontal decrease` |
| `Alt + Shift + =` | `komorebic resize-axis vertical increase` |
| `Alt + Shift + -` | `komorebic resize-axis vertical decrease` |

---

### Manipulate Windows
| Keys | Command |
|------|----------|
| `Alt + T` | `komorebic toggle-float` |
| `Alt + Shift + F` | `komorebic toggle-monocle` |

---

### Move Windows
| Keys | Command |
|------|----------|
| `Alt + Shift + ←` | `komorebic move left` |
| `Alt + Shift + →` | `komorebic move right` |
| `Alt + Shift + ↓` | `komorebic move down` |
| `Alt + Shift + ↑` | `komorebic move up` |
| `Alt + Space` | `komorebic promote` |

---

### Focus on Workspaces
| Keys | Command |
|------|----------|
| `Alt + 1` | `komorebic focus-workspace 0` |
| `Alt + 2` | `komorebic focus-workspace 1` |
| `Alt + 3` | `komorebic focus-workspace 2` |

---

## Move Windows Across Workspaces
| Keys | Command |
|------|----------|
| `Alt + Shift + 1` | `komorebic move-to-workspace 0` |
| `Alt + Shift + 2` | `komorebic move-to-workspace 1` |
| `Alt + Shift + 3` | `komorebic move-to-workspace 2` |

---

### Open Chrome
| Keys | Command |
|------|----------|
| `Alt + W` | `start chrome` |

---

### Open Terminals as User and Administrator
| Keys | Command |
|------|----------|
| `Alt + Return` | `start wt.exe` |
| `Alt + Shift + Return` | `start wt.exe -Verb RunAs` |
| `Alt + C` | `start cmd.exe` |
| `Alt + Shift + C` | `start cmd.exe -Verb RunAs` |

---

### Open File Explorer
| `Alt + F` | `start explorer.exe` |

---

### Open VMWare
| `Alt + V` | `start vmware.exe` |

---

### Open Obsidian
| `Alt + N` | `cmd /c start "" "%LOCALAPPDATA%\Programs\Obsidian\Obsidian.exe"` |

---

### Restart Computer
| Keys | Command |
|------|----------|
| `Alt + 0` | `shutdown /r /t 0` |
</details>



---

## Optional Pre-Install

### Create a [restore point](https://support.microsoft.com/en-us/windows/system-protection-e9126e6e-fa64-4f5f-874d-9db90e57645a)
> [!IMPORTANT]  
> Optional, but recommended.

### If You Want to Change the Desktop Images
- You can preview the current desktop images [here]<link> before installing...
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
- Windows 11 Taskbar Styler
- UXTheme hook

<image>


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
  - **[JetBrainsMono](https://www.programmingfonts.org/#jetbrainsmono)** (Used in the terminal and yasb).
  - **[Clink](https://chrisant996.github.io/clink/clink.html)** (Makes it easy to use Starship in Command Prompt)
  - **[Starship](https://starship.rs/)** (Makes your terminal pretty)
  - **[whkd](https://github.com/LGUG2Z/whkd)** (Makes hot keys work)
 
  **Sets up:**
  - **The [theme](https://www.deviantart.com/niivu/art/Andromeda-11-999859470)** (Applies a theme `Andromeda - Night.theme`...this give you pacman icons in File Explorer...).
  - **Windhawk** (Configures mods).
  - **Environment Variables** (Sets custom environment variables defined in `appList.json`).
  - **Starship** (Adds the initialization line to the user's PowerShell profile).
  - **Komorebi** (Enables autostart).
  - **YASB** (Enables autostart).
  - **Clink** (Disables the Clink banner/logo).
  
  **Other:**
  - **Copies over config files** (Copies dotfiles from `config\home` to `$env:USERPROFILE`).
  - **Copies over theme assets** (Copies files from `config\theme` to `C:\Windows\Resources\Themes`).
  - **Taskbar** (Hides the Windows taskbar).
  - **Sets the Long Paths Enabled registry key** (For Komorebi).
</details>

--- 

## Install Instructions

#### 1. Open Powershell 7 as `Administrator`.
#### 2. Clone the repo **BRANCH: Andromeda** using GitHub Desktop or `git`.
**Using `git`**
```
git clone -b Nordish  https://github.com/blue-pho3nix/blue-windots.git
```
**Using Github Desktop**
- File > clone repo > URL `https://github.com/blue-pho3nix/blue-windots.git`
- Change branch to Nordish

<image>

#### 3. `cd` into the `blue-dots` directory.
#### 4. Run `Setup.ps1`.
> [!NOTE]
> 1. You may need to accept msstore agreements. The default msstore source includes packages in the Microsoft Store.<br>
> 2. You don't need to refresh cache for Windhawk Resource Redirect. <br>
> 3. After the install, make sure to reboot.
```
.\Setup.ps1
```

### 5. Automatically Hide the Taskbar
- `win` + `r` and run `ms-settings:taskbar`

![](https://github.com/user-attachments/assets/ffd39e42-348b-451d-8811-2f7dad6672c8)

- Turn on "Automatically hide the taskbar"

![](https://github.com/user-attachments/assets/80abbafa-091f-4fdc-ae1c-d185a322bc5c)

- Turn off "Hide icon menu"

![](https://github.com/user-attachments/assets/8b64d0cb-83c9-4f56-822c-3e65f8fe43aa)

---

## Post Install Fun

### Let's say you want to edit you Komorebi or WHKD after install.
<details closed>
  <summary>Here's how you can do it. 🎉</summary>

1. Edit and save `C:\Users\<your_username>\Komorebi.json` or `C:\Users\<your_username\.config\whkdrc` 
2. Run `alt` + `r` to restart Komorebi
</details>

### Let's say you want to edit your yasb status bar after install
<details closed>
  <summary>Here's how you can do it. 🎉</summary>

1. Edit and save  `C:\Users\<your_username\.config\yasb\config.yaml` and/or `C:\Users\<your_username\.config\yasb\styles.css` 
</details>

---

## Got Questions, Issues, or Suggestions?
Ping me in #rice on [Discord](https://discord.gg/TujAjYXJjr) (Blue Pho3nix).
