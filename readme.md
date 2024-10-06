# During Install
- During the `pacstrap` install, I would also install `base-devel`, since that will allow you to build aur packages. In addition, I would also install `git, dhcpcd, zsh`, since these will end up needing to be installed later anyways

# Post Install Guide (this part is more for me specifically, but if you wanna read it go ahead)
### Installing a bootloader
- Install the `refind` package from pacman
- Run the command `refind-install`
- Make sure the config file generated has only the "Boot with minimal options" line, other lines generated are for the USB, and will result in a boot fail.
- To make it look decent, install [a theme](https://github.com/bobafetthotmail/refind-theme-regular) using the command `sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/bobafetthotmail/refind-theme-regular/master/install.sh)"`
### Adding a new user
- Add new user using `useradd -m -G [group] -s [shell for user] [username]
- I recommend adding them to the *wheel* group, and editing the 
### Get wireless working
- Install `wireless\_tools iw wpa\_supplicant networkmanager` packages and enable the service by using the command `systemctl enable networkmanager.service`
- Connect to a network using `nmtui`
- If using a DE, there are definitely ways to integrate wpa_supplicant and networkmanager into the DE, but I haven't had to mess with that yet.
### Blutooth
- Install `bluez bluez-utils bluedevil`, and start/enable `bluetooth.service`, you may need to restart. This will get bluetooth working through the KDE settings panel
### Install AUR Packages
- Install `git` package if you don't already have it
- `git clone https://aur.archlinux.org/paru.git` and install it by `cd paru; makepkg -si`
### Getting the XServer working
- Install `xorg xorg-xinit` to have a display server and also start the display server using `startx`
- Install `plasma-desktop kscreen`, this will install KDE without all the extra bloat
- Edit the `.xinitrc` file in your home directory, and add type in these lines:
```
export DESKTOP_SESSION=plasma
exec startplasma-x11
```
### Wayland alternative
- KDE Plasma as of 6.0 comes with X11 and Wayland, I recommend Wayland as it has a more updated codebase. However, there are some reasons to stick to X11 still. Check out (this link)[https://old.reddit.com/r/linux_gaming//wiki/faq#wiki_wayland_or_xorg.3F] for more information on which to use.
- To run KDE, make a script in your home folder and paste the following commands:
```
#!/bin/bash
/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland
```
- If you have an NVIDIA card, you'll need to start linux with the following kernel parameter: `nvidia-drm.modeset=1`.
- For this setup, add that at the end of the **"Boot with minimal options"** line in `/boot/refind\_linux.conf` file.
### Keyboard
- I had a problem with my keyboard where it wasn't properly registering the function keys. This is because it assumed FN lock was on. To fix this, edit `/sys/module/hid\_apple/parameters/fnmode` and set it to zero.
- I would have to do this after every reboot,
### Selecting mirror list
- Go to the [Arch Mirror List Generator](https://www.archlinux.org/mirrorlist/) to get a mirror list that doesn't download at 4 bits a second. Don't forget to uncomment the mirrors.
- If you wanna be extra epic, you can [sort the mirrors by speed](https://wiki.archlinux.org/index.php/mirrors#List_by_speed)
### Getting terminal
- Install `kitty` for the terminal
- Install [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh) and [Powerline Fonts](https://github.com/powerline/fonts) so it looks right (my personal favorite oh-my-zsh theme is 'fino')
### Audio
- Install the following packages: `pipewire pipewire-alsa pipewire-jack pipewire-pulse` to get the Pipewire audio working. Pipewire-pulse helps replease the pulseaudio framework with the imroved Pipewire.
- Install `pwvucontrol` from the AUR to be able to control your audio from a GUI.
### Steam
- Install steam to play games, first you need to enable the **multilib** repo so you can install steam. To do so, edit `/etc/pacman.conf`, and uncomment the lines surrounding `[multilib]`
- Once that's installed, you want to make sure to enable **Proton**, this will allow you play games not compiled for linux, on linux. Thank you Valve. Go to your `Steam Settings > Combatability` and check the box that says `Enable Steam Play for all other titles`
- I'd recommend keeping the default Proton version to be the most recent, that isn't the experimental version.
- There's a community package of Proton that has a bunch of bug fixes that will sometimes be worth trying, it's called **Proton GE**. It's worth trying on a game that might be a bit picky. It's availible on the aur as `proton-ge-custom-bin`
- When trying to get a game to run, check [ProtonDB](https://www.protondb.com/) to see how easy the game is to get to run, as well as what versions of Proton and what launch arguments people used to get their games working
### Screenshots
- To take screenshots, I like to use a program called `flameshot`
- Currently, the arch package for flameshot is behind, and doesn't support fractional scaling well, so I built it from source via their [GitHub repo](https://github.com/flameshot-org/flameshot)
- For future refrence, uninstalling flameshot simply requires removing all the files listed when installing via the `cmake --install build` command, for me flameshot is the only thing (at the time of install) using the `/usr/local/share` folder, so I can delete the whole folder, make very sure that's the only thing before you delete the root install directory though
- Update on the above: the scaling problem is now happening on build from source, so I just went back to the arch repo install, and am dealing with it until it's fixed.
### Getting display manager
- Install `lightdm lightdm-webkit2-greeter` packages for the display manager, install the [Litarvan](https://github.com/Litarvan/lightdm-webkit-theme-litarvan) theme cause it's amazing
- Set the right greeter for lightdm and the right theme for the webkit2 greeter
- Change the picture in the directory `/usr/share/lightdm-webkit/themes/litarvan/img/background.xxxx.png` to change your background in the login
- To change your user icon, put it in the `/var/lib/AccountsService/icons/` and change your user picture by editing the file in `/var/lib/AccountsService/users/[username]`
- One thing I've noticed is on Wayland, after resuming from sleep my KDE is completely borked. To fix this, the `nvidia-resume` service needs to be enabled/started.
- Additionally, copy the following to the `/etc/modprobe.d/nvidia-power-management.conf` file:
```
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
```
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
- You'll also want to set a kernel parameter for resuming, to do that edit the `/etc/default/grub` file and add `resume=[swap partition]` at the end of the string on the line starting with `GRUB\_CMDLINE\_LINUX\_DEFAULT` (this is for grub only, I switched from grub and I'm too afraid to delete it)
### Application launcher
- Install `rofi` package, and the `papirus-icon-theme` for the icons
- The config file only edits a few things, the icons and the color theme (which is generated with pywal)
- If you want to edit the color theme of rofi, edit the `~/.config/wal/templates/colors-rofi-dark.rasi` file, and rerun pywal using `wal -R`
### Power management
- Install the `tlp tlp-rdw` packages
- Enable the tlp service `systemctl enable tlp` and `systemctl enable tlp-sleep`
- Some laptops require additional packages for tlp: `tp\_smapi acpi\_call`
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

gtk theme: Matcha-dark-alix
vs-code syntax theme: seti
icon theme: numix
file manager: thunar
mouse cursor: openzone
dm: lightdm


## Virtual machine notes
- Also install `libvirtd` and start/enable the `libvirtd.service`
- I needed to create a new disk after the VM creation to set it to VirtIO
- I needed to run `sudo virsh net-audostart default` to get it to autostart the default network on boot
- Don't remove any of the spice stuff or the tablet if you're not doing any VFIO or GPU passthrough, because that's how we see it without a direct GPU passthrough. Likewise, since we are using Spice, we don't need to pass the USB devices through either
