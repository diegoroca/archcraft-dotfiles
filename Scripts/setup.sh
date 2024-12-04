#!/bin/bash

DOTFILES_DIR=~/.dotfiles
BACKUP_DIR=~/.dotfiles_backup

# Install packages with pacman
sudo pacman -S --needed base-devel git
sudo pacman -S neovim
sudo pacman -S ttf-jetbrains-mono-nerd
sudo pacman -S arduino-cli
sudo pacman -S screen
sudo pacman -S texlive
sudo pacman -S texlive-langspanish
sudo pacman -S biber

# Install packages with pacman [multilib]
sudo pacman -Sy steam
sudo pacman -Syu kicad
sudo pacman -Syu --asdeps kicad-library

# Ensure a clean installation of yay
git clone https://aur.archlinux.org/yay-git.git ~/Documents/yay
cd ~/Documents/yay
makepkg -si
cd ~

# Install packages from AUR with yay
yay -S google-chrome
yay -S notion-app-electron
yay -S spotify
yay -S fstl
yay -S sddm-sugar-dark

# Install packages from Flathub
sudo pacman -S flatpak
flatpak install flathub com.bambulab.BambuStudio

# Install from other repositories
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim

# Unistall packages
sudo pacman -R plank
sudo pacman -R firefox

# Move the Themes and Wallpapers to its place
sudo cp -rf ~/.dotfiles/Wallpapers/default.jpg /usr/share/backgrounds/default.jpg

sudo cp -rf ~/.dotfiles/Themes/Focaccia /usr/share/themes/Focaccia

sudo tar -xzvf ~/.dotfiles/Themes/Sddm_Candy.tar.gz -C /usr/share/sddm/themes
sudo cp -rf ~/.dotfiles/Configs/sddm/kde_settings.conf /etc/sddm.conf.d/kde_settings.conf

#Create backup
mkdir $BACKUP_DIR

mv ~/.config/alacritty $BACKUP_DIR/
mv ~/.config/dunst $BACKUP_DIR/
mv ~/.config/galculator $BACKUP_DIR/
mv ~/.config/geany $BACKUP_DIR/
mv ~/.config/gtk-2.0 $BACKUP_DIR/
mv ~/.config/gtk-3.0 $BACKUP_DIR/
mv ~/.config/Kvantum $BACKUP_DIR/
mv ~/.config/networkmanager-dmenu $BACKUP_DIR/
mv ~/.config/nitrogen $BACKUP_DIR/
mv ~/.config/obmenu-generator $BACKUP_DIR/
mv ~/.config/openbox $BACKUP_DIR/
mv ~/.config/qt5ct $BACKUP_DIR/
mv ~/.config/qt6ct $BACKUP_DIR/
mv ~/.config/ranger $BACKUP_DIR/
mv ~/.config/rofi $BACKUP_DIR/
mv ~/.config/Thunar $BACKUP_DIR/
mv ~/.config/viewnior $BACKUP_DIR/
mv ~/.config/xfce4 $BACKUP_DIR/
mv ~/.config/picom-ibhagwan.conf $BACKUP_DIR/
mv ~/.config/picom-jonaburg.conf $BACKUP_DIR/
mv ~/.config/picom-original.conf $BACKUP_DIR/

#Create symlinks
ln -s $DOTFILES_DIR/Configs/alacritty ~/.config/alacritty
ln -s $DOTFILES_DIR/Configs/dunst ~/.config/dunst
ln -s $DOTFILES_DIR/Configs/galculator ~/.config/galculator
ln -s $DOTFILES_DIR/Configs/geany ~/.config/geany
ln -s $DOTFILES_DIR/Configs/gtk-2.0 ~/.config/gtk-2.0
ln -s $DOTFILES_DIR/Configs/gtk-3.0 ~/.config/gtk-3.0
ln -s $DOTFILES_DIR/Configs/Kvantum ~/.config/Kvantum
ln -s $DOTFILES_DIR/Configs/networkmanager-dmenu ~/.config/networkmanager-dmenu
ln -s $DOTFILES_DIR/Configs/nitrogen ~/.config/nitrogen
ln -s $DOTFILES_DIR/Configs/obmenu-generator ~/.config/obmenu-generator
ln -s $DOTFILES_DIR/Configs/openbox ~/.config/openbox
ln -s $DOTFILES_DIR/Configs/qt5ct ~/.config/qt5ct
ln -s $DOTFILES_DIR/Configs/qt6ct ~/.config/qt6ct
ln -s $DOTFILES_DIR/Configs/ranger ~/.config/ranger
ln -s $DOTFILES_DIR/Configs/rofi ~/.config/rofi
ln -s $DOTFILES_DIR/Configs/Thunar ~/.config/Thunar
ln -s $DOTFILES_DIR/Configs/viewnior ~/.config/viewnior
ln -s $DOTFILES_DIR/Configs/xfce4 ~/.config/xfce4
ln -s $DOTFILES_DIR/Configs/picom-ibhagwan.conf ~/.config/picom-ibhagwan.conf
ln -s $DOTFILES_DIR/Configs/picom-jonaburg.conf ~/.config/picom-jonaburg.conf
ln -s $DOTFILES_DIR/Configs/picom-original.conf ~/.config/picom-original.conf

ln -sf $DOTFILES_DIR/Configs/picom.conf ~/.config/picom.conf

# Final configs
git config --global user.name "Diego Roca"
git config --global user.email "roca.diego@icloud.com"
git config --global init.defaultBranch "main"

sudo usermod -aG uucp diego 

flatpak override --user --env=GTK_THEME=Adawita:dark com.bambulab.BambuStudio

echo -e "\e[32mIt seems everything went smoothly :D\e[0m"
echo -e "\e[32mReboot to see the changes\e[0m"
