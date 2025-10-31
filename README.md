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

Feel free to add more hotkeys to `C:\Users\<your_username>\komorebi.ahk`. 

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

## Install Instructions

## Create a restore point 
...incase you want to go back to what you had before the install...

![](https://github.com/user-attachments/assets/fd7175f2-b3cd-45da-8cdb-1bebef62e955)

#### 1. Search for `Create a restore point`.
#### 2. Goto `System Protection`.
#### 2. Select `Configure`.
#### 2. Select `Turn on system protection`.
#### 3. Select `Apply` + `OK`.
#### 4. Select `Create...`.
#### 5. Type a description.
#### 6. Select `Create`.

## Install [Windhawk](https://windhawk.net/) 
Install the following mods under `Explore`

![](https://github.com/user-attachments/assets/761804f9-4c03-4a09-aa10-bf51d34ee62d)

---

### Install UXTheme hook
#### 1. Put `winlogon.exe` and `logonui.exe` in the custom process inclusion list.

![](https://github.com/user-attachments/assets/5a86b125-9009-4780-bde0-cfd271ea937c)

#### 2. The theme will be installed via the script below (might as well just install the rest of the mods now tho).

---

### Install Control Panel Color Fix
#### Normal settings

![](https://github.com/user-attachments/assets/0efd5cad-3ccc-4cdb-b58e-063b38a496ca)

---

### Install Resource Redirect
1. Select the `Bonny` icon theme.

![](https://github.com/user-attachments/assets/83827f17-77ae-43ab-b884-37e776f9d833)

3. Click on yes when it asks to clear the icon cache.

![](https://github.com/user-attachments/assets/4e53a921-f5f8-4bdb-bb45-a1862715767b)

---

### Install Windows 11 Taskbar Styler
- Select the `Matter` theme in settings.

![](https://github.com/user-attachments/assets/7018018e-cd38-44f2-811b-b88bf441bf8e)

---

### Install Windows 11 File Explorer Styler
- Select the `Matter` theme in settings.

![](https://github.com/user-attachments/assets/7864fbed-cd94-4e57-901a-acde8f11bab9)

---

### Install Windows 11 Notification Center Styler
- Select the `Matter` theme in settings.

![](https://github.com/user-attachments/assets/d63c7a18-c601-4f51-8f8e-301e4c109183)

---

### Install Windows 11 Start Menu Styler
#### 1. Select the `Oversimplified$Accentuated` theme in settings.
#### 2. Select Disable the new start menu layout

![](https://github.com/user-attachments/assets/9aa0ca9b-db34-4da9-b0f7-90c72d483506)

---


## Install komorebi, yasb, setup config files, set theme, and other setups.
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

---

## Change Mouse Pointer

#### 1. Right click `blue-windots\cursors\install.inf`

![](https://github.com/user-attachments/assets/79e13efe-01f0-45af-b615-c8fbf168e863)

#### 2. Press win + R and enter `main.cpl`

![](https://github.com/user-attachments/assets/ed2557e9-1a03-4d9e-b675-e4d2875be066)

#### 5. Goto `Pointers`

#### 6. Select `Catppuccin-Mocha-Lavender-Cursors`

![](https://github.com/user-attachments/assets/51b9f211-2d3c-461c-a871-d5038fecc247)

---

## Other Changes You Can Make

### If you have fewer/more than 5 monitors
Change the `blue-windots\config\home\komorebi.json` to meet your needs.

### Edit `C:\Users\<your_username>\komorebi.json` after install
#### 1. After your edits, save the file.  
#### 2. Open a regular powershell.
Or open powerShell as Administrator, if you want to run komorebi with Administrator privileges. (This just makes it so apps that have Administrator privs use komorebi, but may cause issues if there is a vulnerability with komorebi).
#### 3. Stop and start komorebi or reload the configuration.
```
komorebic stop --ahk
```
```
komorebic start --ahk
```
^ Make sure to always use `--ahk` to keep the autohotkeys working.  When you stop/restart komorebi, you'll need to reload autohotkey. <br>
or
```
komorebic reload-configuration
```

#### If you want to change your Desktop image after install
There are 6 images in your `C:\Windows\Resources\Themes\One Dark Pro\Wallpapers` folder.<br>
You can preview the images [here](https://github.com/blue-pho3nix/blue-windots/tree/main/config/theme/One%20Dark%20Pro/Wallpapers) before installing... You can always edit them in your Git clone if you really want the diff background images to be auto-set during installation.

---

If anything doesn't work for you, ping me in #rice on [Discord](https://discord.gg/TujAjYXJjr) (Blue Pho3nix).
