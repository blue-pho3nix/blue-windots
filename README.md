# Windots for Windows 11 😊
My semi-automated [Komorebi](https://github.com/LGUG2Z/Komorebi) + [yasb](https://github.com/amnweb/yasb) setup.

![](https://github.com/user-attachments/assets/e066d4de-a5d7-4814-a120-0d6c89ef5ea3)
![](https://github.com/user-attachments/assets/e84b909d-a3e5-4a1a-9e1c-77ac08140aa7)
![](https://github.com/user-attachments/assets/f226badf-40bc-48bc-93b9-101909dabddd)
![](https://github.com/user-attachments/assets/9dfb0651-10c4-44cb-9695-ece71834e40d)
![](https://github.com/user-attachments/assets/538eeeb4-8bc7-428d-9b77-390423a9a29c)
![](https://github.com/user-attachments/assets/29a57724-c0f4-4e63-8de5-503c2f3175e6)
![](https://github.com/user-attachments/assets/23662d7f-ec4a-4a8a-b65d-564578d23e93)
![](https://github.com/user-attachments/assets/f9a9d884-3fb9-454b-8396-052f36ae746d)


## Hotkeys
> [!NOTE]
> Feel free to add more [AutoHotKeys](https://www.autohotkey.com/) to `C:\Users\<your_username>\Komorebi.ahk`. 

<details closed>
  <summary>View the cool hotkeys 🔥</summary>

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
> At this point, you can manually install the mods, and the setup for each mod (except UXTheme Hook) will be in the script below.

#### Install the following mods under `Explore`
- Control Panel Color Fix
- Resource Redirect
- Windows 11 File Explorer Styler
- Windows 11 Notification Center Styler
- Windows 11 Start Menu Styler
- Windows 11 Taskbar Styler
- UXTheme hook

> [!NOTE]
> You don't need to ensure `winlogon.exe` and `logonui.exe`  are in windhawk's process inclusion list, in its advanced settings of UXTheme hook. The theme doesn't really have settings for the login/lock screen.

![](https://github.com/user-attachments/assets/9006bdf4-dab3-41b7-95d5-9796e36aca2a)

### 2. Install Powershell 7
```
winget install Microsoft.PowerShell
```

---

## What Does the Script Do?

<details closed>
  <summary> The script does the following 💙...</summary>
  
  **Installs:**
  - **Winget-CLI** (This installs the applications)
  - [Windows Terminal](https://apps.microsoft.com/detail/9n0dx20hk701?hl=en-US&gl=US) (You need this for the terminal hotkeys).
  - **[Komorebi](https://github.com/LGUG2Z/komorebi)** (Windows tiling manager).
  - **[yasb](https://github.com/amnweb/yasb)** (Status bar at the top of the screen).
  - **[OhMyPosh](https://ohmyposh.dev/)** (Just installed to make nerd font installation easier).  
  - **[0xProto Nerd Font](https://www.programmingfonts.org/#oxproto)** (Used in the terminal and yasb).
  - **[AutoHotkey](https://www.autohotkey.com/)** (Makes it possible to use the windown key in hotkeys).
  - **[Clink](https://chrisant996.github.io/clink/clink.html)** (Makes it easy to use Starship in Command Prompt)
  - **[Starship](https://starship.rs/)** (Makes your terminal pretty)
 

  **Sets up:**
  - **The theme** (Applies a theme `One Dark Pro (Night) - PAC.theme`...this give you packman icons in File Explorer...).
  - **Windhawk** (Configures mods).
  - **Environment Variables** (Sets custom environment variables defined in `appList.json`).
  - **Starship** (Adds the initialization line to the user's PowerShell profile).
  - **Komorebi** (Starts the engine and enables autostart).
  - **YASB** (Starts the engine and enables autostart).
  - **Clink** (Disables the Clink banner/logo).
  
  **Other:**
  - **copies over config files** (Copies dotfiles from `config\home` to `$env:USERPROFILE`).
  - **copies over theme assets** (Copies files from `config\theme` to `C:\Windows\Resources\Themes`).
  - **toggles off clock in taskbar** (Hides the taskbar clock).
  - **Sets** the Long Paths Enabled registry key for Komorebi.
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

```
.\Setup.ps1
```

---

## Post Install Fun

### Change Your Mouse Pointer
<details closed>
  <summary> Install <a href="https://www.deviantart.com/niivu/art/Catppuccin-Cursors-921387705" target="_blank">Catppuccin Cursors - Lavender</a> 🖱️ </summary>
  
   1. Clone the repo using GitHub Desktop, `git`, or download as a .zip.
   ```
   git clone https://github.com/blue-pho3nix/blue-windots.git
   ```
   2. Right click blue-windots\cursors\install.inf.
    
  ![](https://github.com/user-attachments/assets/79e13efe-01f0-45af-b615-c8fbf168e863)
  
  3. Press `win + R` and enter `main.cpl`.
  
  ![](https://github.com/user-attachments/assets/ed2557e9-1a03-4d9e-b675-e4d2875be066)
  
  4. Goto `Pointers`.
  5. Select `Catppuccin-Mocha-Lavender-Cursors`
  
  ![](https://github.com/user-attachments/assets/51b9f211-2d3c-461c-a871-d5038fecc247)
  
  6. Click `Apply` and `OK`.

</details>

### Let's say you want to edit you Komorebi config file after install.
<details closed>
  <summary>Here's how you can do it. 🎉</summary>

1. Edit and save `C:\Users\<your_username>\Komorebi.json`   
2. Open a regular powershell window (`win + enter`).
3. Stop and start Komorebi or reload the configuration.
> Make sure to always use `--ahk` to keep the autohotkeys working. <br>
> When you stop/restart Komorebi, you'll need to reload AutoHotKey. 

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
</details>

---

## Got Questions, Issues, or Suggestions?
Ping me in #rice on [Discord](https://discord.gg/TujAjYXJjr) (Blue Pho3nix).
