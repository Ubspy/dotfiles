# Post Install Guide (this part is more for me specifically, but if you wanna read it go ahead)
### Adding a new user
- Add new user using `useradd -m -G [group] -s [shell for user] [username]`
### Get wireless working
- Install `wireless_tools iw wpa_supplicant networkmanager` packages and enable the service by using the command `systemctl enable networkmanager.service`
- Connect to a network using `nmtui`
### Install AUR Packages
- Install `git` package if you don't somehow already have it
- `git clone https://github.com/trizen/trizen` and install it by `cd trizen; makepkg -si`
### Getting the XServer working
- Install `xorg xorg-xinit` to have a display server and also start the display server using `startx`
- Install `i3-gaps` package so you have a GUI interface
### Selecting mirror list
- Go to the [Arch Mirror List Generator](https://www.archlinux.org/mirrorlist/) to get a mirror list that doesn't download at 4 bits a second. Don't forget to uncomment the mirrors.
- If you wanna be extra epic, you can [sort the mirrors by speed](https://wiki.archlinux.org/index.php/mirrors#List_by_speed)
### Getting terminal
- Install `termite` for the terminal
- Install [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh) and [Powerline Fonts](https://github.com/powerline/fonts) so it looks right (my personal favorite oh-my-zsh theme is 'fino')
### Getting display manager
- Install `lightdm lightdm-webkit2-greeter` packages for the display manager, install the [Litarvan](https://github.com/Litarvan/lightdm-webkit-theme-litarvan) theme cause it's amazing
- Set the right greeter for lightdm and the right theme for the webkit2 greeter
- Change the picture in the directory `/usr/share/lightdm-webkit/themes/litarvan/img/background.xxxx.png` to change your background in the login
### Visual Studio Code
- Install `code` package to get visual studio code text editor
### Set Wallpaper
- Install `feh` package and set it to run on login in your i3 config file
### Compositor
- You'll notice the screen has some tearing, and there's no transparency, this is why we install a composite manager
- Install `compton-tyrone-git` from the AUR since it has blur
- To get the config working correctly, do a lot of googling, my config file is a good start
### Color themes
- Install `python-pywal` package and run `wal -i /path/to/image` to set the image that dictates the color themes

## TODO List
[-] Get better cursor theme
[-] Get user icon and set it in lightdm
[-] Get a better status bar
[-] Get a better application launcher
[-] Get better gtk theme
[-] Put new config files into repo 

gtk theme: Matcha-dark-alix
atom syntax theme: seti
icon theme: numix
file manager: thunar
mouse cursor: openzone
dm: lightdm
