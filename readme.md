# Post Install Guide (this part is more for me specifically, but if you wanna read it go ahead)

### Installing a bootloader
- Install the `refind-efi` package from pacman
- Run the command `refind-install`
- To make it look decent, install [a theme](https://github.com/bobafetthotmail/refind-theme-regular) using the command `sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/bobafetthotmail/refind-theme-regular/master/install.sh)"`

### Adding a new user
- Add new user using `useradd -m -G [group] -s [shell for user] [username]`

### Theme
I'm using the `Snow-alien` theme, but I modified the colors to match my wallpaper. Incase I have to do this in the future, here are the following colors I replaced, this only changes the ugly green they use by default for the main selection color (and deselected color):
```css
#758173             -> #a50100
rgba(117,129,115    -> rgba(165,1,0
#697467             -> #a41602
rgba(105, 116, 103  -> rgba(164,22,2
```
You need to change these values in both the gtk.css and the gtk-dark.css file. Also I intentionally left the last argument of `rbga` off, because you want to replace the color at whatever transparency.

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
- To change your user icon, put it in the `/var/lib/AccountsService/icons/` and change your user picture by editing the file in `/var/lib/AccountsService/users/[username]`

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

### Get locker
- Install `i3lock-color-git` from AUR
- Install `i3lock-fancy-git` from AUR and edit the script file so the opacity looks acceptable
- I had to change the opacity so it wasn't completly dark, that was on like the 4th line `hue=(-level "0%,100%,1")` the last number in there is the opacity, by default it's 0.6

### Set sleep functionality
- Edit the `/etc/systemd/logind.conf` file and set the appropriate parameters (mine should be in this repo)
- To sleep on inactivity, I tried using the systemd functionality but nothing happened, so I used the `xautolock` package to do this, it runs in the i3 config

### Get computer to lock on sleep
- Make a service in systemd (attached in dotfiles) to handle locking on suspend
- The service in the dotfiles is set up so you can activate them for different users, you just need to specify when activating the service with `systemctl enable i3lock@user.service`
- Important note: if you're using `suspend-then-hibernate` then you probably want to set the hibernate time because the default is three hours, to do that edit the `HibernateDelaySec` line in the `/etc/systemd/sleep.conf` file
- You'll also want to set a kernel parameter for resuming, to do that edit the `/etc/default/grub` file and add `resume=[swap partition]` at the end of the string on the line starting with `GRUB_CMDLINE_LINUX_DEFAULT` (this is for grub only, I switched from grub and I'm too afraid to delete it)

### Application launcher
- Install `rofi` package, and the `papirus-icon-theme` for the icons
- The config file only edits a few things, the icons and the color theme (which is generated with pywal)
- If you want to edit the color theme of rofi, edit the `~/.config/wal/templates/colors-rofi-dark.rasi` file, and rerun pywal using `wal -R`

### Power management
- Install the `tlp tlp-rdw` packages
- Enable the tlp service `systemctl enable tlp` and `systemctl enable tlp-sleep`
- Some laptops require additional packages for tlp: `tp_smapi acpi_call`

### File manager
- Install the `thunar thunar-volman gvfs tumbler` packages
- That's literally it

### Polybar
- Install `polybar-git` from the AUR
- Install `otf-font-awesome` from pacman
- Configuring is lots of "fun"

## TODO List
- [ ] Get better cursor theme
- [x] Get user icon and set it in lightdm
- [ ] Get a better status bar
- [x] Get a better application launcher
- [ ] Get better gtk theme
- [x] Put new config files into repo 
- [x] Find a way to lock the computer
- [ ] Make install script
- [ ] Get programs to autostart on login
- [x] Power Management
- [ ] Get Fn lock to work

gtk theme (window border): Matcha-dark-aliz

gtk theme (actual gtk+): Snow-alien (modified)

vs-code syntax theme: seti

icon theme: numix

file manager: thunar

mouse cursor: openzone

dm: lightdm
