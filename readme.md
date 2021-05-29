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

### Tmp Theme
I'm using the `Arc-DARKEST` theme, but I modified the colors to match my wallpaper. Incase I have to do this in the future, here is how I did that. This theme uses a gresource file, so you need the `gdm` package to extract the internal gtk css files:
```
gresource extract gtk.gresource /org/gnome/arc-theme/gtk-main-dark.css > gtk.css
gresource extract gtk.gresource /org/gnome/arc-theme/gtk-main-dark.css > gtk-dark.css
```

This will replace the the files referencing the `.gresource` file with the actual css stored in there. You can then go into those files and replace the following string patterns:
```css
#2285e2             -> #a50100
rgba(34, 133, 226   -> rgba(165, 1, 0
```
You need to change these values in both the gtk.css and the gtk-dark.css file. Also I intentionally left the last argument of `rbga` off, because you want to replace the color at whatever transparency.

### Get wireless working
- Install `wpa_supplicant networkmanager nm-applet` packages and enable the service by using the command `systemctl enable networkmanager.service` and `systemctl enable wpa_supplicant.service`
- You'll connect to networks using `nm-applet`

### Install AUR Packages
- Install `git` package if you don't somehow already have it
- `git clone https://github.com/trizen/trizen` and install it by `cd trizen; makepkg -si`

### Getting the XServer working
- Install `xorg xorg-xinit` to have a display server and also start the display server using `startx`
- Install `xfce4` package so you have a GUI interface

### Selecting mirror list
- Go to the [Arch Mirror List Generator](https://www.archlinux.org/mirrorlist/) to get a mirror list that doesn't download at 4 bits a second. Don't forget to uncomment the mirrors.
- If you wanna be extra epic, you can [sort the mirrors by speed](https://wiki.archlinux.org/index.php/mirrors#List_by_speed)

### Getting terminal
- Install `alacritty` for the terminal
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

### Application launcher
- Install `ulauncher` package

## Gaming virtual machine setup
### Install the packages
First you want to get the following packages: `virt-manager qemu`.

### Set up IOMMU
IOMMU is what we will be using to isolate the gpu so we can pass it directly to the virtual machine.
Add the following to your kernel parameters: `amd_iommu=on iommu=pt` (for grub, edit the `/etc/default/grub` file and remake the config), you'll need to reboot for this to take affect.
Run the following command to make sure that iommu is properly enabled: `dmesg | grep -i -e DMAR -e IOMMU`.

### Find the iommu group for your gpu
This script will list the iommu groups you have, as well as the device ids. You want to find the ids for your gpu, as well as everything inside that group. To pass something into a vm, you need to pass in the entire group, you can't just pass in a single device.
```bash
#!/bin/bash
shopt -s nullglob
for g in `find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V`; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```

### Isolating the gpu on boot
I'm currently not doing this, but you follow [this section from the arch wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Isolating_the_GPU).
You need two graphics devices for this, my current setup has one so move onto the next section.

### Setting up libvirt hooks for single gpu
I could write a guide here, but it's all perfectly laid out in [this github page](https://github.com/joeknock90/Single-GPU-Passthrough).

### Downloading the images
You need two iso files for this, first you'll need the Windows 10 iso, and you'll also need the [virtio drivers](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md).

### Setting up the vm
You'll want to pick install from iso, and then select your windows 10 iso (I'd recommend setting up your own directory for images for virt-manager).
Give the machine as much RAM as you think is necessary, but be sure to only give it a single cpu.
Create a disk, and you can leave everything else default, but be sure to select edit before installing.

Once you're in the big menu, you'll want to delete a few things: the tablet, display spice, console, channel spice, video QXL, and both USB redirectors.
Next, go to the CPU settings, set it to copy host CPU information, and manually edit the topology, set two threads and however many cores you want to give it (one socket, obviously).

Then go to boot options and set the `SATA CDROM 1` and the virtual disk to be the boot devices. Go to the virtual disk you're installing on and set the mode to `VirtIO` instead of `SATA`, it's much faster. Then go to the advanced and change the cache mdoe to `writeback`, it's the fastest.

If you're like me, you have your games on a hard drive, you can add another storage device with the same settings, but set it to the location of the `/dev/` in the file path.

Next, you want to add another storage for your virtio drivers. It'll be a CD ROM, but speed doesn't matter so don't bother with the cache mode.

Finally, add all the PCI devices for everything in your GPU IOMMU group, as well as any USB devices you'll need (mouse, keyboard, headphones, etc).

### On boot
When you boot up, you'll need to install the virtio drivers to install it on the virtio virtual disk. Then you can install Windows 10 on the virtio virtual disk.
Once it's installed, install the virtio network drivers and windows will take care of the rest. Now you have a working gaming vm!

### If you're using wifi
If you're using wifi with a single gpu, you'll want to follow [this guide](https://ubuntu.forumming.com/question/9718/stay-connected-to-wifi-when-all-users-log-out) to keep the wifi going even when you're logged out.

gtk theme (window border): Matcha-dark-aliz

gtk theme (actual gtk+): Arc-BLACKEST (modified)

vs-code syntax theme: seti

icon theme: ePapirus

file manager: thunar

mouse cursor: openzone

dm: lightdm