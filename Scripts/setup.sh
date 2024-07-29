#!/bin/bash

DOTFILES_DIR=~/.dotfiles
BACKUP_DIR=~/.dotfiles_backup

# Unistall packages
sudo pacman -R plank
sudo pacman -R firefox

# Install packages with pacman
sudo pacman -S --needed base-devel
sudo pacman -S neovim
sudo pacman -S ttf-jetbrains-mono-nerd
sudo pacman -S arduino-cli
sudo pacman -S texlive
sudo pacman -S texlive-langspanish
sudo pacman -S biber

# Install packages with pacman [multilib]
sudo pacman -Sy steam

# Install packages form AUR with yay
yay -S google-chrome
yay -S notion-app-electron
yay -S spotify

# Install from other repositories
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim

# Move the Themes and Wallpapers to its place
sudo cp -f ~/.dotfiles/Wallpapers/default.jpg /usr/share/backgrounds/default.jpg
sudo cp -f ~/.dotfiles/Wallpapers/catslug.png /usr/share/backgrounds/catslug.png

sudo cp -f ~/.dotfiles/Themes/Focaccia /usr/share/themes/Focaccia
sudo cp -f ~/.dotfiles/Themes/Catslug /usr/share/themes/Catslug

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
ln -s $DOTFILES_DIR/alacritty ~/.config/alacritty
ln -s $DOTFILES_DIR/dunst ~/.config/dunst
ln -s $DOTFILES_DIR/galculator ~/.config/galculator
ln -s $DOTFILES_DIR/geany ~/.config/geany
ln -s $DOTFILES_DIR/gtk-2.0 ~/.config/gtk-2.0
ln -s $DOTFILES_DIR/gtk-3.0 ~/.config/gtk-3.0
ln -s $DOTFILES_DIR/Kvantum ~/.config/Kvantum
ln -s $DOTFILES_DIR/networkmanager-dmenu ~/.config/networkmanager-dmenu
ln -s $DOTFILES_DIR/nitrogen ~/.config/nitrogen
ln -s $DOTFILES_DIR/nvim/lua/chadrc.lua ~/.config/nvim/lua/chadrc.lua
ln -s $DOTFILES_DIR/obmenu-generator ~/.config/obmenu-generator
ln -s $DOTFILES_DIR/openbox ~/.config/openbox
ln -s $DOTFILES_DIR/qt5ct ~/.config/qt5ct
ln -s $DOTFILES_DIR/qt6ct ~/.config/qt6ct
ln -s $DOTFILES_DIR/ranger ~/.config/ranger
ln -s $DOTFILES_DIR/rofi ~/.config/rofi
ln -s $DOTFILES_DIR/Thunar ~/.config/Thunar
ln -s $DOTFILES_DIR/viewnior ~/.config/viewnior
ln -s $DOTFILES_DIR/xfce4 ~/.config/xfce4
ln -s $DOTFILES_DIR/picom-ibhagwan.conf ~/.config/picom-ibhagwan.conf
ln -s $DOTFILES_DIR/picom-jonaburg.conf ~/.config/picom-jonaburg.conf
ln -s $DOTFILES_DIR/picom-original.conf ~/.config/picom-original.conf

ln -sf $DOTFILES_DIR/picom.conf ~/.config/picom.conf

# Final configs
git config --global user.name "Diego Roca"
git config --global user.email "roca.diego@icloud.com"
