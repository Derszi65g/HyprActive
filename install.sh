#!/bin/bash

# --- Configuración ---
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_CONFIG_DIR="$HOME/.config"
DEST_WALLHYPR_DIR="$HOME"

# --- Dependencias (Unificadas para Paru) ---
# Paru gestionará la instalación desde los repositorios oficiales y el AUR.
# Se han corregido los nombres de los paquetes (ej. wl-clipboard) y añadido dependencias faltantes.
ALL_DEPS=(
    "hyprland" "kitty" "waybar" "rofi" "swww" "dunst" "grim" "slurp"
    "wl-clipboard" # Contiene wl-paste
    "cliphist" "thunar" "brightnessctl"
    "libpulse" # Contiene pactl
    "zenity" "power-profiles-daemon" "ttf-jetbrains-mono-nerd" "wlr-randr" "jq"
    "xdg-desktop-portal-hyprland" # Para mejor integración de Waybar y portales
    "hellwal" # Dependencia de AUR
)

# --- Funciones ---

check_and_install_dependencies() {
    echo "----------------------------------------"
    echo "--- Comprobando Dependencias con Paru---"
    echo "----------------------------------------"

    # --- Comprobar si Paru está instalado ---
    if ! command -v paru &> /dev/null; then
        echo "ADVERTENCIA: El ayudante de AUR 'paru' no está instalado."
        echo "Es necesario para gestionar todas las dependencias."
        read -p "¿Quieres intentar instalar 'paru' ahora? (S/n): " choice
        if [[ "$choice" =~ ^[Ss]?$ ]]; then
            # Instalar dependencias para compilar y git
            sudo pacman -S --noconfirm --needed base-devel git
            # Clonar y compilar paru
            git clone https://aur.archlinux.org/paru.git /tmp/paru
            (cd /tmp/paru && makepkg -si --noconfirm)
            # Limpiar
            rm -rf /tmp/paru
        else
             echo "No se puede continuar sin 'paru'. Abortando."
             exit 1
        fi
    fi

    # --- Comprobar todas las dependencias (oficiales y AUR) ---
    local missing_deps=()
    for dep in "${ALL_DEPS[@]}"; do
        # Usamos pacman -Q que es rápido y funciona para paquetes de repo y AUR una vez instalados
        if ! pacman -Q "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Las siguientes dependencias no están instaladas:"
        printf " - %s\n" "${missing_deps[@]}"
        read -p "¿Deseas instalarlas ahora con 'paru'? (S/n): " choice
        if [[ "$choice" =~ ^[Ss]?$ ]]; then
            paru -S --noconfirm --needed "${missing_deps[@]}"
        else
            echo "Instalación de dependencias cancelada. El script no puede continuar."
            exit 1
        fi
    else
        echo "Todas las dependencias ya están instaladas."
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
cp -rfvT "$SOURCE_DIR/.config/" "$DEST_CONFIG_DIR/"

# 4. Copiar la carpeta de wallpapers
echo "Copiando la carpeta de wallpapers a $DEST_WALLHYPR_DIR..."
cp -rfv "$SOURCE_DIR/wallhypr/"* "$DEST_WALLHYPR_DIR/wallhypr/"

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
echo "Recuerda reiniciar tu sesión de Hyprland para que todos los cambios surtan efecto."
