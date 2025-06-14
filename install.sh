#!/usr/bin/env bash
set -e

update_system() {
  echo "🔧 Mise à jour du système..."
  sudo pacman -Syu --noconfirm
}

install_packages() {
  echo "📦 Installation des paquets..."
  local pkgs=(
    zsh alacritty neovim wofi waybar swww mako thunar lf
    cliphist wl-clipboard ttf-iosevka-nerd ttf-jetbrains-mono-nerd
    noto-fonts-emoji chezmoi networkmanager network-manager-applet
    bluez bluez-utils blueman openssh unzip
    lm_sensors acpi acpi_call
  )
  sudo pacman -S --noconfirm "${pkgs[@]}"
}

install_yay() {
  echo "📦 Vérification de yay..."
  if ! command -v yay &>/dev/null; then
    echo "⬇️  Installation de yay depuis l'AUR..."
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir"
    cd "$tmpdir"
    makepkg -si --noconfirm
    cd -
    rm -rf "$tmpdir"
  fi
}

install_aur_packages() {
  echo "📦 Installation des paquets AUR..."
  yay -S --noconfirm brave-bin swaylock-effects papirus-icon-theme papirus-folders
}

set_zsh_default() {
  echo "🐚 Configuration de zsh comme shell par défaut..."
  sudo chsh -s /bin/zsh "$USER"
}

setup_icons() {
  echo "🎨 Configuration du thème d'icônes..."
  git clone https://github.com/catppuccin/papirus-folders.git
  cd papirus-folders
  sudo cp -r src/* /usr/share/icons/Papirus/
  cd ..
  rm -rf papirus-folders
  papirus-folders -C cat-mocha-blue --theme Papirus
}

verify_packages() {
  echo "🔍 Vérification des paquets installés..."
  local all_pkgs=(
    zsh alacritty neovim wofi waybar swww mako thunar lf
    cliphist wl-clipboard ttf-iosevka-nerd ttf-jetbrains-mono-nerd
    noto-fonts-emoji chezmoi networkmanager network-manager-applet
    bluez bluez-utils blueman openssh unzip
    lm_sensors acpi acpi_call
    brave-bin swaylock-effects papirus-icon-theme papirus-folders
  )
  local not_found=()
  for pkg in "${all_pkgs[@]}"; do
    pacman -Q "$pkg" &>/dev/null || yay -Q "$pkg" &>/dev/null || not_found+=("$pkg")
  done

  if [ ${#not_found[@]} -eq 0 ]; then
    echo "✅ Tous les paquets sont installés avec succès !"
  else
    echo "❌ Certains paquets manquent :"
    for p in "${not_found[@]}"; do echo "  - $p"; done
    exit 1
  fi
}

enable_services() {
  echo "🌐 Activation des services..."
  sudo systemctl enable --now NetworkManager
  sudo systemctl enable --now bluetooth
  sudo systemctl enable --now sshd
  sudo systemctl enable --now lm_sensors.service
}

detect_sensors() {
  echo "🌡️  Détection automatique des capteurs..."
  sudo sensors-detect --auto
}

main() {
  update_system
  install_packages
  install_yay
  install_aur_packages
  set_zsh_default
  setup_icons
  verify_packages
  enable_services
  detect_sensors

  echo "🎉 Installation complète terminée sans accroc !"
}

main "$@"