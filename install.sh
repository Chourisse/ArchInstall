#!/usr/bin/env bash
set -e

echo "🔧 Mise à jour du système et installation des paquets requis..."
sudo pacman -Syu --noconfirm
PKG_LIST=(zsh alacritty neovim wofi waybar swww mako thunar lf cliphist wl-clipboard ttf-iosevka-nerd noto-fonts-emoji chezmoi networkmanager network-manager-applet bluez bluez-utils blueman openssh)
sudo pacman -S --noconfirm "${PKG_LIST[@]}"

echo "🐚 Configuration de zsh comme shell par défaut..."
sudo chsh -s /bin/zsh $USER

echo "📦 Vérification de yay..."
if ! command -v yay &>/dev/null; then
  echo "⬇️  Installation de yay depuis l'AUR..."
  git clone https://aur.archlinux.org/yay.git
  cd yay && makepkg -si --noconfirm
  cd ..
  rm -rf yay
fi

echo "📦 Installation des paquets AUR..."
yay -S --noconfirm brave-bin swaylock-effects papirus-icon-theme papirus-folders ttf-maple-font-git

echo "🎨 Configuration du thème d'icônes..."
git clone https://github.com/catppuccin/papirus-folders.git
cd papirus-folders
sudo cp -r src/* /usr/share/icons/Papirus/
cd ..
rm -rf papirus-folders
papirus-folders -C cat-mocha-blue --theme Papirus

echo "🔠 Configuration de la police Maple Mono avec fallback..."
mkdir -p ~/.config/fontconfig
cat > ~/.config/fontconfig/fonts.conf <<EOF
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Maple Mono</family>
      <family>Iosevka Nerd Font</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF

echo "🧹 Rafraîchissement du cache de polices..."
fc-cache -fv

echo "🔍 Vérification finale..."
ALL_PKGS=("${PKG_LIST[@]}" swaylock-effects papirus-icon-theme papirus-folders ttf-maple-font-git)
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

echo "🌐 Activation des services réseau, bluetooth et SSH..."
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable sshd
sudo systemctl start sshd
echo "✅ Services activés avec succès !"