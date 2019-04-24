# Post Install Guide (this part is more for me specifically, but if you wanna read it go ahead)
### Adding a new user
- Add new user using `useradd -m -G [group] -s [shell for user] [username]`
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

gtk theme: Matcha-dark-alix
atom syntax theme: seti
icon theme: numix
file manager: thunar
mouse cursor: openzone
dm: lightdm
