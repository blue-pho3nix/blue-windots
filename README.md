# Windots for Windows 11 😊
My semi-automated [komorebi](https://github.com/LGUG2Z/komorebi) + [yasb](https://github.com/amnweb/yasb) setup.

![](https://github.com/user-attachments/assets/e066d4de-a5d7-4814-a120-0d6c89ef5ea3)
![](https://github.com/user-attachments/assets/e84b909d-a3e5-4a1a-9e1c-77ac08140aa7)
![](https://github.com/user-attachments/assets/f226badf-40bc-48bc-93b9-101909dabddd)
![](https://github.com/user-attachments/assets/9dfb0651-10c4-44cb-9695-ece71834e40d)
![](https://github.com/user-attachments/assets/538eeeb4-8bc7-428d-9b77-390423a9a29c)
![](https://github.com/user-attachments/assets/29a57724-c0f4-4e63-8de5-503c2f3175e6)
![](https://github.com/user-attachments/assets/23662d7f-ec4a-4a8a-b65d-564578d23e93)
![](https://github.com/user-attachments/assets/f9a9d884-3fb9-454b-8396-052f36ae746d)


# Hotkeys
- Feel free to add more hotkeys to `C:\Users\<your_username>\komorebi.ahk`. 

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

---

## Optional Pre-Install

### Change Your Mouse Pointer
<details closed>
  <summary> Install <a href="https://www.deviantart.com/niivu/art/Catppuccin-Cursors-921387705" target="_blank">Catppuccin Cursors - Lavender</a> </summary>
  
   1. Clone the repo using GitHub Desktop, `git`, or <a href="https://github.com/blue-pho3nix/blue-windots/archive/refs/heads/make-windhawk-install-easier.zip" target="_blank">download as a .zip</a>.
   ```
   git clone https://github.com/blue-pho3nix/blue-windots.git
   ```
   2. Right click blue-windots\cursors\install.inf
    
  ![](https://github.com/user-attachments/assets/79e13efe-01f0-45af-b615-c8fbf168e863)
  
  3. Press win + R and enter `main.cpl`
  
  ![](https://github.com/user-attachments/assets/ed2557e9-1a03-4d9e-b675-e4d2875be066)
  
  4. Goto `Pointers`
  5. Select `Catppuccin-Mocha-Lavender-Cursors`
  
  ![](https://github.com/user-attachments/assets/51b9f211-2d3c-461c-a871-d5038fecc247)
  
  6. Click `Apply` and `OK`.

</details>


### Create a <a href="https://support.microsoft.com/en-us/windows/system-protection-e9126e6e-fa64-4f5f-874d-9db90e57645a" target="_blank">restore point</a>
> [!IMPORTANT]  
> Optional, but recommended.

### If You Want to Change the Desktop Images
- You can preview the current desktop images [here](https://github.com/blue-pho3nix/blue-windots/tree/main/config/theme/One%20Dark%20Pro/Wallpapers) before installing...
- You can always edit them in your Git clone if you want the diff background images to be auto-set to slideshow during installation.

---

## Required Pre-Install

> [!TIP]
> If You have **fewer/more than 5 monitors**, change the `blue-windots\config\home\komorebi.json` to meet your needs.

### 1. Install [Windhawk](https://windhawk.net/) 
> [!NOTE]
> I want to script the entire install for windhawk, but windhawk is not currently set up to do so... <br>
> At this point, you can manually install the mods, and the setup for each mod will be in the script below.

#### Install the following mods under `Explore`
- Control Panel Color Fix
- Resource Redirect
- UXTheme hook
- Windows 11 File Explorer Styler
- Windows 11 Notification Center Styler
- Windows 11 Start Menu Styler
- Windows 11 Taskbar Styler

You Windhawk home should look like this:

![](https://github.com/user-attachments/assets/9006bdf4-dab3-41b7-95d5-9796e36aca2a)

### 5. Install Windows Powershell


### 6. Install Powershell 7
```
winget install Microsoft.PowerShell
```

---

## Install Instructions

The script installs:
- 

Sets up: 


Changes: 
- komorebi, yasb, copies over config files, sets the theme, sets up windhawk, installs 0xProto Nerd Font toggles off clock in taskbar.

1. Open Powershell 7 as `Administrator`

![](https://github.com/user-attachments/assets/7fc94ff5-aad9-49b7-9820-1b60f710aafc)

2. Clone the repo using GitHub Desktop, `git`, or [download as a .zip](https://github.com/blue-pho3nix/blue-windots/archive/refs/heads/make-windhawk-install-easier.zip) .

```
git clone https://github.com/blue-pho3nix/blue-windots.git
```
3. `cd` into `blue-dots`
4. Run `Setup.ps1`

```
.\Setup.ps1
```

---


## More Info

Let's say you want to edit you komorebi config file after install. <br>

### Here's how you can do it

1. Edit `C:\Users\<your_username>\komorebi.json` 
2. Save the file.  
3. Open a regular powershell window (`win + enter`).
4. Stop and start komorebi or reload the configuration.
> Make sure to always use `--ahk` to keep the autohotkeys working.  When you stop/restart komorebi, you'll need to reload autohotkey. 
```
komorebic stop --ahk
```
```
komorebic start --ahk
```
or
```
komorebic reload-configuration
```

---
## Got Questions, Issues, or Suggestions?
Ping me in #rice on [Discord](https://discord.gg/TujAjYXJjr) (Blue Pho3nix).
