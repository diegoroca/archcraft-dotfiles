# Dotfiles for Archcraft

### 1. Install and update [Archcraft](https://archcraft.io/download.html)

Instructions on how to install Archcraft [here](https://wiki.archcraft.io/docs/intro/)

After installing Archcraft connect your machine to internet and update it with the following command

```bash
$ sudo pacman -Syyu
```

### 2. Configure the packages list

Enable [multilib] uncommenting the `[multilib]` int the file `/etc/pacman.conf` at this point you can use `sudo vim` to easily edit the file.

```bash
sudo vim /etc/pacman.conf
```

Update the packages list again

```bash
sudo pacman -Sy
```

### 3. Install the ricing

Finally you can reboot the machine and run the install script

```bash
git clone git@github.com:diegoroca/archcraft-dotfiles.git ~/.dotfiles
cd .dotfiles/Scripts
chmod +x setup.sh
./setup.sh
```

### 4. Last Settings

Google Chrome

- Set google-chrome title bar to use system title bar
- Set dns to google public dns
- Set google to start where I left
- Disable ambient mode and stable volume in youtube

Steam

- Enable compatibility mode with the latest stable version of proton
- Install some games

---

### Helpful documentation found in the way

[How to use the AUR (Arch User Repository) and how yay works](https://www.youtube.com/watch?v=EYiN8vDkacc)

[How tf polybar is customized once for all](https://www.youtube.com/watch?v=tOBDUBEMAKM)

[Polybar documentation in its github wiki](https://github.com/polybar/polybar/wiki/Formatting)

[Change the login screen with SDD or something](https://www.youtube.com/watch?v=zavHnAzqaEQ)

[What are and how to use dot files](https://www.youtube.com/watch?v=r_MpUP6aKiQ)

[More about dotfiles](https://www.youtube.com/watch?v=W4Dq_4seq8w)

[https://github.com/newmanls/rofi-themes-collection](https://github.com/newmanls/rofi-themes-collection)

[https://github.com/adi1090x/rofi](https://github.com/adi1090x/rofi)
