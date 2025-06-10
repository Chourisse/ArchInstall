#!/usr/bin/env bash
set -e

echo "🔧 Mise à jour du système et installation des paquets requis..."
sudo pacman -Syu --noconfirm
PKG_LIST=(zsh alacritty neovim wofi waybar swww mako thunar lf cliphist wl-clipboard ttf-iosevka-nerd noto-fonts noto-fonts-emoji chezmoi networkmanager network-manager-applet bluez bluez-utils blueman)
sudo pacman -S --noconfirm "${PKG_LIST[@]}"

echo "🐚 Configuration de zsh comme shell par défaut..."
chsh -s /bin/zsh

echo "📦 Vérification de yay..."
if ! command -v yay &>/dev/null; then
  echo "⬇️  Installation de yay depuis l'AUR..."
  git clone https://aur.archlinux.org/yay.git
  cd yay && makepkg -si --noconfirm
  cd ..
  rm -rf yay
fi

echo "📦 Installation des paquets AUR..."
yay -S --noconfirm brave-bin swaylock-effects papirus-icon-theme papirus-folders

echo "🎨 Configuration du thème d'icônes..."
git clone https://github.com/catppuccin/papirus-folders.git
cd papirus-folders
sudo cp -r src/* /usr/share/icons/Papirus/
cd ..
rm -rf papirus-folders
papirus-folders -C cat-mocha-blue --theme Papirus

echo "🔍 Vérification finale..."
ALL_PKGS=("${PKG_LIST[@]}" swaylock-effects papirus-icon-theme papirus-folders)
NOT_FOUND=()
for pkg in "${ALL_PKGS[@]}"; do 
  pacman -Q "$pkg" &>/dev/null || yay -Q "$pkg" &>/dev/null || NOT_FOUND+=("$pkg")
done
if [ ${#NOT_FOUND[@]} -eq 0 ]; then 
  echo "✅ Tous les paquets sont installés avec succès !"
else
  echo "❌ Certains paquets n'ont pas pu être installés :"
  for p in "${NOT_FOUND[@]}"; do echo "  - $p"; done
  exit 1
fi

echo "🌐 Activation des services réseau et bluetooth..."
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
sudo systemctl enable bluetooth
echo "✅ Services activés avec succès !"