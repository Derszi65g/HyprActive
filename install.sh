#!/bin/bash

# --- Configuración ---
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_CONFIG_DIR="$HOME/.config"
DEST_WALLHYPR_DIR="$HOME"

# --- Dependencias ---
# Paquetes de repositorios oficiales de Arch Linux
PACMAN_DEPS=(
    "hyprland" "kitty" "waybar" "rofi" "swww" "dunst" "grim" "slurp" 
    "wl-paste" "cliphist" "thunar" "brightnessctl" "pactl" "zenity" 
    "power-profiles-daemon" "ttf-jetbrains-mono-nerd" "wlr-randr" "jq"
)

# Paquetes de AUR
AUR_DEPS=("hellwal")

# --- Funciones ---

check_and_install_dependencies() {
    echo "----------------------------------------"
    echo "--- Comprobando Dependencias...      ---"
    echo "----------------------------------------"

    # --- Repositorios Oficiales (Pacman) ---
    local missing_pacman_deps=()
    for dep in "${PACMAN_DEPS[@]}"; do
        if ! pacman -Q "$dep" &> /dev/null; then
            missing_pacman_deps+=("$dep")
        fi
    done

    if [ ${#missing_pacman_deps[@]} -gt 0 ]; then
        echo "Las siguientes dependencias de pacman no están instaladas:"
        printf " - %s\n" "${missing_pacman_deps[@]}"
        read -p "¿Deseas instalarlas ahora? (S/n): " choice
        if [[ "$choice" =~ ^[Ss]?$ ]]; then
            sudo pacman -S --noconfirm --needed "${missing_pacman_deps[@]}"
        else
            echo "Instalación de dependencias cancelada. El script no puede continuar."
            exit 1
        fi
    else
        echo "Todas las dependencias de pacman ya están instaladas."
    fi

    # --- AUR (Paru) ---
    local missing_aur_deps=()
    for dep in "${AUR_DEPS[@]}"; do
        if ! pacman -Q "$dep" &> /dev/null; then
            missing_aur_deps+=("$dep")
        fi
    done

    if [ ${#missing_aur_deps[@]} -gt 0 ]; then
        echo "Las siguientes dependencias de AUR no están instaladas:"
        printf " - %s\n" "${missing_aur_deps[@]}"
        if ! command -v paru &> /dev/null; then
            echo "ADVERTENCIA: El ayudante de AUR 'paru' no está instalado."
            echo "Por favor, instálalo para poder instalar dependencias de AUR automáticamente."
            read -p "¿Quieres intentar instalar 'paru' ahora? (S/n): " choice
            if [[ "$choice" =~ ^[Ss]?$ ]]; then
                sudo pacman -S --needed base-devel git
                git clone https://aur.archlinux.org/paru.git /tmp/paru
                (cd /tmp/paru && makepkg -si --noconfirm)
            else
                 echo "No se puede continuar sin un ayudante de AUR. Abortando."
                 exit 1
            fi
        fi
        read -p "¿Deseas instalar las dependencias de AUR con 'paru'? (S/n): " choice
        if [[ "$choice" =~ ^[Ss]?$ ]]; then
            paru -S --noconfirm --needed "${missing_aur_deps[@]}"
        else
            echo "Instalación de dependencias de AUR cancelada. El script no puede continuar."
            exit 1
        fi
    else
        echo "Todas las dependencias de AUR ya están instaladas."
    fi
}

# --- Script Principal ---

# 1. Comprobar e instalar dependencias
check_and_install_dependencies

echo "
Iniciando la instalación de los dotfiles de HyprActive..."

# 2. Crear directorios necesarios
mkdir -p "$DEST_CONFIG_DIR"
mkdir -p "$DEST_WALLHYPR_DIR/wallhypr"

# 3. Copiar los archivos de configuración
echo "Copiando archivos de configuración a $DEST_CONFIG_DIR..."
cp -rvT "$SOURCE_DIR/.config/" "$DEST_CONFIG_DIR/"

# 4. Copiar la carpeta de wallpapers
echo "Copiando la carpeta de wallpapers a $DEST_WALLHYPR_DIR..."
cp -rv "$SOURCE_DIR/wallhypr/"* "$DEST_WALLHYPR_DIR/wallhypr/"

# 5. Configurar monitores
echo "Ejecutando el script de configuración de monitores..."
if [ -f "$SOURCE_DIR/moni.sh" ]; then
    chmod +x "$SOURCE_DIR/moni.sh"
    bash "$SOURCE_DIR/moni.sh"
else
    echo "ADVERTENCIA: No se encontró 'moni.sh'. Saltando configuración del monitor."
fi

# 6. Establecer el fondo de pantalla inicial
echo "Estableciendo el fondo de pantalla inicial..."
WALLPAPER_SCRIPT="$DEST_CONFIG_DIR/rofi/bin/WallSelecthypr"
WALLPAPER_PATH="$DEST_WALLHYPR_DIR/wallhypr/Tunnel.png"

if [ -f "$WALLPAPER_SCRIPT" ]; then
    if [ -f "$WALLPAPER_PATH" ]; then
        chmod +x "$WALLPAPER_SCRIPT"
        bash "$WALLPAPER_SCRIPT" -D dark -C "$WALLPAPER_PATH"
    else
        echo "ADVERTENCIA: No se encontró el wallpaper por defecto en $WALLPAPER_PATH."
    fi
else
    echo "ADVERTENCIA: No se encontró 'WallSelecthypr'."
fi

echo ""
echo "¡Instalación completada!"
