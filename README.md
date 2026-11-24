# Dotfiles for Archcraft

### 1. Install [Archcraft](https://archcraft.io/download.html)

Instructions on how to install Archcraft [here](https://wiki.archcraft.io/docs/intro/). Make sure to install Openbox as the window manager, then connect the machine to the internet.

### 2. Run the setup script

```bash
git clone https://github.com/diegoroca/archcraft-dotfiles.git ~/.dotfiles
~/.dotfiles/Scripts/setup.sh
```

The script does everything in one go and can be re-run safely (finished steps are skipped):

- Enables `[multilib]` and updates the system
- Installs packages (pacman, AUR via `yay`, Flathub) and removes Plank and Firefox
- Installs themes, icons, wallpaper and the SDDM login theme
- Symlinks every config in `Configs/` into `~/.config` (anything replaced is saved in `~/.dotfiles_backup/<date>/`)
- Applies the Neovim (NvChad) customizations
- **macOS-style keyboard** with [keyd](https://github.com/rvaiya/keyd): left Alt = Cmd, Super = Option, Ctrl = Spaces. System config in `Configs/keyd/default.conf` (copied to `/etc/keyd/`), per-app rules in `Configs/keyd/app.conf` applied by `Scripts/bin/keyd-app-focus.py`
- **Xbox button opens Steam** (`guide-steam` user service, with controller rumble and a notification)
- `reboot-windows`: reboots straight into Windows once (EFI `BootNext`)

Reboot when it finishes. To push changes to this repo, log in with `gh auth login`.

### 3. Last Settings

Google Chrome

- Set Chrome title bar to use system title bar
- Set DNS to google public DNS
- Set Chrome to start where I left
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
