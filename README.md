# Windots 😊
My personal Windows 11 windots for a semi-automated [komorebi](https://github.com/LGUG2Z/komorebi) + [yasb](https://github.com/amnweb/yasb) setup.

## Install komorebi, yasb and setup config files
- Clone the repo
```
git clone blue-pho3nix/blue-windots
```
- Open Powershell 7 as Administrator

- `cd` into `blue-dots`
- Run `Setup.ps1`
```
.\Setup.ps1
```

## Install [Windhawk](https://windhawk.net/) 
Install the following mods

### Control Panel Color Fix
- Normal settings

### Resource Redirect
- Download the [Delta Icon theme](https://www.deviantart.com/niivu/art/DELTA-for-Windows-11-1250579496)

- Put the `Windhawk Resource Redirect > Delta` folder somewhere like Documents. Then, list the path in theme paths.
<br> Example:

![](https://github.com/user-attachments/assets/7d2db809-dad4-41a5-93eb-c77b3f70d930)

### UXTheme hook
- Put `winlogon.exe` and `logonui.exe` in the custom process inclusion list.

![](https://github.com/user-attachments/assets/5a86b125-9009-4780-bde0-cfd271ea937c)

- Click on `Allow themes to change desktop icons` in `Personalization > Themes > Desktop icon settings`.

![](https://github.com/user-attachments/assets/81b96814-cb1a-4574-87d1-275a98001192)

- From [Delta Icon theme](https://www.deviantart.com/niivu/art/DELTA-for-Windows-11-1250579496), put the `.theme` files and `Delta/Delta2` folders in `Windows 11 Themes by niivu` into `C:\Windows\Resources\Themes` folder.
- From [One Dark Pro Theme](https://www.deviantart.com/niivu/art/One-Dark-Pro-for-Windows-11-930312689), put the `.theme` files and `One Dark Pro` in `Windows 11 22H2 Themes` into `C:\Windows\Resources\Themes` folder.
- Goto `Personalization > Themes` in settings.
- Click on any of the `Delta` themes to set the folder...etc icons.
- Click on `One Dark Pro (Night) - PAC` to set the pacman file explorer icons.

![](https://github.com/user-attachments/assets/c07ed3c6-b1a0-4729-ab6f-b0442f4fe31d)

### Windows 11 Taskbar Styler
- Select `SimplyTransparent` in settings.

## Other
- Change background images to images in `wallpaper`.
- Turn off `Show time and date in the System tray` at `Time & language > Date & time`.
  
![](https://github.com/user-attachments/assets/4968053b-24ae-4d6f-8d20-3046ca17990a)

- Follow these [instructions](https://www.deviantart.com/niivu/art/Installing-Windows-Themes-UPDATED-708835586) for extra options.
