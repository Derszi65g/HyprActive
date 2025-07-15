#!/bin/bash

# Directorio de origen (donde se encuentra el script)
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directorio de destino para .config
DEST_CONFIG_DIR="$HOME/.config"

# Directorio de destino para wallhypr
DEST_WALLHYPR_DIR="$HOME"

# --- Instalación ---

echo "Iniciando la instalación de los dotfiles de HyprActive..."

# 1. Crear el directorio .config en HOME si no existe
if [ ! -d "$DEST_CONFIG_DIR" ]; then
    echo "El directorio $DEST_CONFIG_DIR no existe. Creándolo..."
    mkdir -p "$DEST_CONFIG_DIR"
fi

# 2. Copiar los archivos de configuración de .config
echo "Copiando archivos de configuración a $DEST_CONFIG_DIR..."
cp -rvT "$SOURCE_DIR/.config/" "$DEST_CONFIG_DIR/"

# 3. Copiar la carpeta de wallpapers
echo "Copiando la carpeta de wallpapers a $DEST_WALLHYPR_DIR..."
cp -rv "$SOURCE_DIR/wallhypr" "$DEST_WALLHYPR_DIR/"

# 4. Configurar monitores ejecutando el script dedicado
echo "Ejecutando el script de configuración de monitores..."
if [ -f "$SOURCE_DIR/moni.sh" ]; then
    chmod +x "$SOURCE_DIR/moni.sh"
    bash "$SOURCE_DIR/moni.sh"
else
    echo "ADVERTENCIA: No se encontró el script 'moni.sh'. Saltando la configuración del monitor."
fi

# 5. Establecer el fondo de pantalla inicial
echo "Estableciendo el fondo de pantalla inicial..."
WALLPAPER_SCRIPT="$DEST_CONFIG_DIR/rofi/bin/WallSelecthypr"
WALLPAPER_PATH="$DEST_WALLHYPR_DIR/wallhypr/Tunnel.png"

if [ -f "$WALLPAPER_SCRIPT" ]; then
    if [ -f "$WALLPAPER_PATH" ]; then
        chmod +x "$WALLPAPER_SCRIPT"
        bash "$WALLPAPER_SCRIPT" -D dark -C "$WALLPAPER_PATH"
    else
        echo "ADVERTENCIA: No se encontró el wallpaper por defecto en $WALLPAPER_PATH."
        echo "Saltando el establecimiento del fondo de pantalla."
    fi
else
    echo "ADVERTENCIA: No se encontró el script 'WallSelecthypr'. Saltando el establecimiento del fondo de pantalla."
fi

echo ""
echo "¡Instalación completada!"
echo "Asegúrate de instalar todas las dependencias listadas en el README.md"