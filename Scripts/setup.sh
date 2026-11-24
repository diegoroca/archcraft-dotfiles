#!/bin/bash
# Reproduce el setup completo sobre una instalación limpia de Archcraft (Openbox).
#
#   git clone https://github.com/diegoroca/archcraft-dotfiles.git ~/.dotfiles
#   ~/.dotfiles/Scripts/setup.sh
#
# Se puede volver a ejecutar sin problema: lo que ya está hecho se salta.
# Lo que se reemplaza se guarda en ~/.dotfiles_backup/<fecha>/.

set -uo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y-%m-%d_%H%M%S)"
FAILED=()

step() { echo -e "\n\e[1;34m==> $*\e[0m"; }
warn() { echo -e "\e[33m  ! $*\e[0m"; FAILED+=("$*"); }
run()  { "$@" || warn "falló: $*"; }

# Enlaza $1 (en el repo) en $2, guardando lo que hubiera antes en el backup
link() {
    local src="$1" dst="$2"
    [ "$(readlink -f "$dst" 2>/dev/null)" = "$(readlink -f "$src")" ] && return
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/" || { warn "no se pudo respaldar $dst"; return; }
    fi
    ln -s "$src" "$dst" || warn "no se pudo enlazar $dst"
}

[ "$(id -u)" -eq 0 ] && { echo "Ejecútalo como tu usuario, no como root."; exit 1; }
[ -d "$DOTFILES_DIR/.git" ] || { echo "Clona el repo en $DOTFILES_DIR primero."; exit 1; }
sudo -v || exit 1

# ---------------------------------------------------------------- pacman
step "Habilitando multilib y actualizando el sistema"
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
fi
run sudo pacman -Syu --noconfirm

step "Instalando paquetes de los repositorios oficiales"
PACMAN_PKGS=(
    base-devel git neovim ttf-jetbrains-mono-nerd kitty github-cli
    arduino-cli screen texlive texlive-langspanish biber
    steam kicad flatpak
    keyd python-xlib maim xdotool efibootmgr      # atajos macOS, capturas, reboot-windows
)
run sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
pacman -Qq kicad-library >/dev/null 2>&1 || run sudo pacman -S --needed --noconfirm --asdeps kicad-library

step "Placas de Arduino"
run arduino-cli core update-index
run arduino-cli core install arduino:avr
run arduino-cli core install esp32:esp32

step "Quitando paquetes que no se usan"
for p in plank firefox; do
    pacman -Qq "$p" >/dev/null 2>&1 && run sudo pacman -Rns --noconfirm "$p"
done

# ---------------------------------------------------------------- AUR
step "Instalando yay"
if ! command -v yay >/dev/null; then
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay" && (cd "$tmp/yay" && makepkg -si --noconfirm) \
        || warn "no se pudo instalar yay"
    rm -rf "$tmp"
fi

step "Instalando paquetes de AUR"
# rofi-lbonn-wayland-git reemplaza a rofi: yay preguntará si quitar el conflicto.
AUR_PKGS=(google-chrome notion-app-electron spotify fstl sddm-sugar-dark obconf uxplay rofi-lbonn-wayland-git)
command -v yay >/dev/null && run yay -S --needed "${AUR_PKGS[@]}"

# ---------------------------------------------------------------- Flatpak
step "Instalando apps de Flathub"
FLATPAKS=(app.zen_browser.zen com.bambulab.BambuStudio com.discordapp.Discord
          info.cemu.Cemu moe.tsuna.tsukimi org.jellyfin.JellyfinDesktop)
run sudo flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
run sudo flatpak install --system -y flathub "${FLATPAKS[@]}"
run flatpak override --user --env=GTK_THEME=Adwaita:dark com.bambulab.BambuStudio

# ---------------------------------------------------------------- Temas
step "Temas, iconos, fondo y pantalla de inicio"
run sudo install -Dm644 "$DOTFILES_DIR/Wallpapers/default.jpg" /usr/share/backgrounds/default.jpg
run sudo cp -rfT "$DOTFILES_DIR/Themes/Focaccia" /usr/share/themes/Focaccia
# Steam corre en un contenedor que no ve /usr/share/themes: necesita el tema en ~/.themes
link "$DOTFILES_DIR/Themes/Focaccia" "$HOME/.themes/Focaccia"
run sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d
run sudo tar -xzf "$DOTFILES_DIR/Themes/Sddm_Candy.tar.gz" -C /usr/share/sddm/themes
run sudo install -Dm644 "$DOTFILES_DIR/Configs/sddm/kde_settings.conf" /etc/sddm.conf.d/kde_settings.conf

if [ ! -d "$HOME/.local/share/icons/WhiteSur-yellow-dark" ]; then
    tmp=$(mktemp -d)
    git clone --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$tmp/whitesur" && (
        cd "$tmp/whitesur" && ./install.sh -a && ./install.sh -a -t orange && ./install.sh -a -t yellow
    ) || warn "no se pudieron instalar los iconos WhiteSur"
    rm -rf "$tmp"
fi

# ---------------------------------------------------------------- Configs
step "Enlazando configuraciones"
for c in alacritty betterlockscreen dunst galculator geany gtk-2.0 gtk-3.0 keyd kitty Kvantum \
         networkmanager-dmenu nitrogen obmenu-generator openbox qt5ct qt6ct ranger rofi \
         Thunar viewnior xfce4 \
         picom-ibhagwan.conf picom-jonaburg.conf picom-original.conf; do
    link "$DOTFILES_DIR/Configs/$c" "$HOME/.config/$c"
done
# picom.conf se copia en vez de enlazarse: el apply.sh de los temas de Archcraft
# lo edita con sed -i, lo que rompe el enlace de todos modos.
[ -e "$HOME/.config/picom.conf" ] && { mkdir -p "$BACKUP_DIR"; cp "$HOME/.config/picom.conf" "$BACKUP_DIR/"; }
rm -f "$HOME/.config/picom.conf"
run cp "$DOTFILES_DIR/Configs/picom.conf" "$HOME/.config/picom.conf"
link "$DOTFILES_DIR/Configs/systemd/user/guide-steam.service" "$HOME/.config/systemd/user/guide-steam.service"

step "Scripts de usuario (~/.local/bin)"
for s in "$DOTFILES_DIR"/Scripts/bin/*; do
    chmod +x "$s"
    link "$s" "$HOME/.local/bin/$(basename "$s")"
done

step "Neovim (NvChad + ajustes propios)"
if [ ! -d "$HOME/.config/nvim" ]; then
    run git clone https://github.com/NvChad/starter "$HOME/.config/nvim"
fi
run cp -rf "$DOTFILES_DIR/Configs/nvim/." "$HOME/.config/nvim/"
run nvim --headless "+Lazy! sync" +qa

# ---------------------------------------------------------------- Servicios
step "keyd (teclado estilo macOS)"
run sudo install -Dm644 "$DOTFILES_DIR/Configs/keyd/default.conf" /etc/keyd/default.conf
run sudo usermod -aG keyd "$USER"
run sudo systemctl enable --now keyd
run sudo keyd reload

step "Botón Xbox del mando abre Steam"
run systemctl --user daemon-reload
run systemctl --user enable --now guide-steam.service

step "reboot-windows (reiniciar directo en Windows)"
run sudo install -Dm755 "$DOTFILES_DIR/Scripts/system/efi-next-windows" /usr/local/bin/efi-next-windows
SUDOERS_TMP=$(mktemp)
echo "$USER ALL=(root) NOPASSWD: /usr/local/bin/efi-next-windows" > "$SUDOERS_TMP"
if sudo visudo -cf "$SUDOERS_TMP" >/dev/null; then
    run sudo install -m440 "$SUDOERS_TMP" /etc/sudoers.d/efi-next-windows
else
    warn "regla de sudoers inválida, no se instaló"
fi
rm -f "$SUDOERS_TMP"

# ---------------------------------------------------------------- Final
step "Ajustes finales"
run betterlockscreen -u "$DOTFILES_DIR/Wallpapers/default.jpg"
git config --global user.name "Diego Roca"
git config --global user.email "roca.diego@icloud.com"
git config --global init.defaultBranch "main"
run sudo usermod -aG uucp "$USER"

echo
if [ ${#FAILED[@]} -eq 0 ]; then
    echo -e "\e[32mTodo salió bien :D\e[0m"
else
    echo -e "\e[33mTerminado con ${#FAILED[@]} aviso(s):\e[0m"
    printf '  - %s\n' "${FAILED[@]}"
fi
[ -d "$BACKUP_DIR" ] && echo "Configs anteriores guardadas en $BACKUP_DIR"
echo -e "\e[32mReinicia para aplicar todos los cambios (grupos keyd/uucp, keyd, SDDM).\e[0m"
echo "Pendiente a mano: gh auth login (para hacer push a este repo)."
