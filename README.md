# Windots for Windows 11 😊
My semi-automated [komorebi](https://github.com/LGUG2Z/komorebi) + [yasb](https://github.com/amnweb/yasb) setup.



# Komorebi AutoHotkey v2 Hotkeys

Feel free to add more to ``. 

| Hotkey | Action |
|--------|--------|
| `win` + `Left` | Focus window to the left |
| `win` + `Right` | Focus window to the right |
| `win` + `Up` | Focus window upward |
| `win` + `Down` | Focus window downward |
| `win` + `=` | Increase window width (horizontal) |
| `win` + `-` | Decrease window width (horizontal) |
| `win` + `shift` + `=` | Increase window height (vertical) |
| `win` + `shift` + `-` | Decrease window height (vertical) |
| `win` + `Space` | Promote focused window |
| `win` + `1` | Focus workspace 1 |
| `win` + `2` | Focus workspace 2 |
| `win` + `3` | Focus workspace 3 |
| `win` + `4` | Focus workspace 4 |
| `win` + `shift` + `1` | Move window to workspace 1 |
| `win` + `shift` + `2` | Move window to workspace 2 |
| `win` + `shift` + `3` | Move window to workspace 3 |
| `win` + `shift` + `4` | Move window to workspace 4 |
| `win` + `shift` + `Left` | Move window left (includes monitors) |
| `win` + `shift` + `Right` | Move window right (includes monitors) |
| `win` + `w` | Open default browser (Google) |
| `win` + `Enter` | Open PowerShell |
| `win` + `shift` + `Enter` | Open PowerShell as Administrator |
| `win` + `c` | Open Command Prompt |
| `win` + `shift` + `c` | Open Command Prompt as Administrator |
| `win` + `f` | Open File Explorer |
| `win` + `q` | Close focused window |

## Install Instructions

## Create a restore point
#### 1. Select `Configure`
#### 2. Select `Turn on system protection`
#### 3. Select `Apply` + `OK`
#### 4. Select `Create...`
#### 5. Type a description
#### 6. Select `Create`


## Install komorebi, yasb and setup config files
#### 1. Install [Windows Terminal](https://apps.microsoft.com/detail/9N0DX20HK701)
#### 2. Clone the repo using [GitHub Desktop](https://desktop.github.com/download/) or  `git`.
```
git clone https://github.com/blue-pho3nix/blue-windots.git
```
#### 3. Open Windows terminal as `Administrator`

![](https://github.com/user-attachments/assets/a0397a54-bd11-410a-92e1-726867cbd94e)

#### 4. `cd` into `blue-dots`
#### 5. Run `Setup.ps1`
```
.\Setup.ps1
```

## Install [Windhawk](https://windhawk.net/) 
Install the following mods

---

### Control Panel Color Fix
#### Normal settings

---

### Resource Redirect
#### 1. Download [Delta Icon theme](https://www.deviantart.com/niivu/art/DELTA-for-Windows-11-1250579496) or another theme...

#### 2. Put the `Windhawk Resource Redirect > Delta` folder somewhere like Documents. Then, list the path in theme paths.
Example:

![](https://github.com/user-attachments/assets/7d2db809-dad4-41a5-93eb-c77b3f70d930)

---

### UXTheme hook
#### 1. Put `winlogon.exe` and `logonui.exe` in the custom process inclusion list.

![](https://github.com/user-attachments/assets/5a86b125-9009-4780-bde0-cfd271ea937c)

#### 2. Click on `Allow themes to change desktop icons` in `Personalization > Themes > Desktop icon settings`.

![](https://github.com/user-attachments/assets/81b96814-cb1a-4574-87d1-275a98001192)

#### 4. From [Delta Icon theme](https://www.deviantart.com/niivu/art/DELTA-for-Windows-11-1250579496), put the `.theme` files and `Delta/Delta2` folders in `Windows 11 Themes by niivu` into `C:\Windows\Resources\Themes` folder.
#### 5. From [One Dark Pro Theme](https://www.deviantart.com/niivu/art/One-Dark-Pro-for-Windows-11-930312689), put the `.theme` files and `One Dark Pro` in `Windows 11 22H2 Themes` into `C:\Windows\Resources\Themes` folder.
#### 6. Goto `Personalization > Themes` in settings.
#### 7. Click on any of the `Delta` themes to set the desktop icons.
#### 8. Click on `One Dark Pro (Night) - PAC` to set the pacman file explorer icons.

![](https://github.com/user-attachments/assets/c07ed3c6-b1a0-4729-ab6f-b0442f4fe31d)

---

### Windows 11 Taskbar Styler
- Select the `Matter` theme in settings.

![](https://github.com/user-attachments/assets/c22fa41a-a145-4939-907b-2eef3d69790e)

---

### Windows 11 File Explorer Styler
- Select the `Matter` theme in settings.

![](https://github.com/user-attachments/assets/91090801-c968-4a98-997a-849ee4100520)

---

### Windows 11 Notification Center Styler
- Select the `Matter` theme in settings.

![](https://github.com/user-attachments/assets/d07f3aec-45a7-41ca-a908-5d30428a2009)

---

### Windows 11 Start Menu Styler
#### 1. Select the `SideBySide` theme in settings.
#### 2. Select Disable the new start menu layout

![](https://github.com/user-attachments/assets/1f015452-fd6b-4ad9-859c-9259cbac4518)

## Change Mouse Pointer

#### 1. Download [Catppuccin Cursors](https://www.deviantart.com/niivu/art/Catppuccin-Cursors-921387705)
#### 2. Choose a color pointer (I chose `mocha > Catppuccin-Mocha-Dark-Cursors`)
#### 3. Right click on install.inf and select install
#### 4. Open Control Panel
#### 5. Select Large Icons (If not already selected)
#### 6. Select Mouse 
#### 7. Goto `Pointers`
#### 8. Select `Catppuccin-Mocha-Dark-Cursors`

![](https://github.com/user-attachments/assets/5821d288-9392-4b71-a435-f4a9c3951122)


## Other
- Change background to images in `blue-windots\wallpaper`.
- Turn off `Show time and date in the System tray` at `Time & language > Date & time`.

![](https://github.com/user-attachments/assets/4968053b-24ae-4d6f-8d20-3046ca17990a)

- Change [taskbar app icons](https://www.deviantart.com/dpcdpc11/journal/HOW-TO-CHANGE-THE-APP-ICONS-IN-THE-WINDOWS-TASKBAR-891158884).
