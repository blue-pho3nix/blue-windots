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

## Pre Install

### If you want to change your Desktop images
- You can preview the current desktop images [here](https://github.com/blue-pho3nix/blue-windots/tree/main/config/theme/One%20Dark%20Pro/Wallpapers) before installing... You can always edit them in your Git clone if you really want the diff background images to be auto-set to slideshow during installation.

### If you have fewer/more than 5 monitors
- Change the `blue-windots\config\home\komorebi.json` to meet your needs.

---

## Install Instructions

### 1. Create a restore point 
- ...incase you want to go back to what you had before the install...

![](https://github.com/user-attachments/assets/fd7175f2-b3cd-45da-8cdb-1bebef62e955)

1. Search for `Create a restore point`.
2. Goto `System Protection`.
3. Select `Configure`.
4. Select `Turn on system protection`.
5. Select `Apply` + `OK`.
6. Select `Create...`.
7. Type a description.
8. Select `Create`.

### 2. Install [Windhawk](https://windhawk.net/) 
I want to script the entire install for windhawk, but it's not currently set up to do so... <br>
At this point, you can install the mods, and the setup for each mod will be in the script below.

### Install the following mods under `Explore`

![](https://github.com/user-attachments/assets/761804f9-4c03-4a09-aa10-bf51d34ee62d)

- Control Panel Color Fix
- Resource Redirect
- UXTheme hook
- Windows 11 File Explorer Styler
- Windows 11 Notification Center Styler
- Windows 11 Start Menu Styler
- Windows 11 Taskbar Styler

It should look like this:

![](https://github.com/user-attachments/assets/9006bdf4-dab3-41b7-95d5-9796e36aca2a)

---

## Install komorebi, yasb, copy over config files, set theme, setup windhawk, toggle off clock in taskbar.

1. Install Powershell 7
```
winget install Microsoft.PowerShell
```

2. Open Powershell 7 as `Administrator`

![](https://github.com/user-attachments/assets/7fc94ff5-aad9-49b7-9820-1b60f710aafc)

3. Clone the repo using GitHub Desktop, `git`, or [download as a .zip](https://github.com/blue-pho3nix/blue-windots/archive/refs/heads/make-windhawk-install-easier.zip) .

```
git clone https://github.com/blue-pho3nix/blue-windots.git
```

4. `cd` into `blue-dots`
5. Run `Setup.ps1`

```
.\Setup.ps1
```

---

## Change Mouse Pointer

1. Right click `blue-windots\cursors\install.inf`

![](https://github.com/user-attachments/assets/79e13efe-01f0-45af-b615-c8fbf168e863)

2. Press win + R and enter `main.cpl`

![](https://github.com/user-attachments/assets/ed2557e9-1a03-4d9e-b675-e4d2875be066)

3. Goto `Pointers`

4. Select `Catppuccin-Mocha-Lavender-Cursors`

![](https://github.com/user-attachments/assets/51b9f211-2d3c-461c-a871-d5038fecc247)

5. Click `Apply` and `OK`.

---

## Install [Windows Terminal](https://apps.microsoft.com/detail/9N0DX20HK701?hl=en-us&gl=US&ocid=pdpshare)
- You need this for the terminal hotkeys.
- Either install it or change the hotkeys in `C:\Users\<your_username>\komorebi.ahk`.

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
