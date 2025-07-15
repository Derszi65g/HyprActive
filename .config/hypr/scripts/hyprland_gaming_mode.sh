#!/bin/bash

# Script para activar/desactivar un modo "gaming" en Hyprland

# --- CONFIGURACIÓN ---
# Comandos para lanzar tus servicios. Ajústalos si es necesario.
WAYBAR_COMMAND="waybar -c /home/dereck/.config/waybar/config-hypr -s /home/dereck/.config/waybar/style.css &"
SWWW_DAEMON_COMMAND="swww-daemon &"
CLIPHIST_TEXT_COMMAND="wl-paste --type text --watch cliphist store &"
CLIPHIST_IMAGE_COMMAND="wl-paste --type image --watch cliphist store &"

# --- SCRIPT ---
STATE_FILE="/tmp/hyprland_gaming_mode.lock"

notify() {
    if command -v notify-send &> /dev/null; then
        notify-send -t 3000 "$1" "$2"
    else
        echo "$1: $2"
    fi
}

# Función para matar procesos de forma segura por su línea de comandos
kill_by_cmd() {
    pkill -f "$1"
}

if [ -f "$STATE_FILE" ]; then
    # --- MODO GAMING ACTIVO, PROCEDEMOS A DESACTIVARLO ---
    notify "Modo Gaming" "Desactivado. Restaurando entorno."
    powerprofilesctl set balanced

    # 1. Restauramos todos los ajustes visuales recargando la config original
    hyprctl reload

    # 2. Esperamos un instante para que el reload se complete
    sleep 1

    # 3. Relanzamos explícitamente los procesos que matamos
    if ! pgrep -x "waybar" > /dev/null; then
        eval "$WAYBAR_COMMAND"
    fi
    # Relanzamos dunst con systemctl si es posible, si no, de forma normal
    if systemctl --user list-units --full -all | grep -q "dunst.service"; then
        systemctl --user start dunst.service
    elif ! pgrep -x "dunst" > /dev/null; then
        dunst &
    fi
    if ! pgrep -x "swww-daemon" > /dev/null; then
        eval "$SWWW_DAEMON_COMMAND"
    fi
    if ! pgrep -f "wl-paste --type text --watch cliphist store" > /dev/null; then
        eval "$CLIPHIST_TEXT_COMMAND"
    fi
    if ! pgrep -f "wl-paste --type image --watch cliphist store" > /dev/null; then
        eval "$CLIPHIST_IMAGE_COMMAND"
    fi

    # 4. Eliminamos el archivo de estado
    rm "$STATE_FILE"
else
    # --- MODO GAMING INACTIVO, PROCEDEMOS A ACTIVARLO ---
    notify "Modo Gaming" "Activado. Desactivando efectos."
    powerprofilesctl set performance

    # Matamos los procesos
    killall waybar
    # Detener dunst con systemctl para evitar reinicios, con fallback a killall
    systemctl --user stop dunst.service >/dev/null 2>&1 || killall dunst
    killall swww-daemon
    kill_by_cmd "wl-paste --type text --watch cliphist store"
    kill_by_cmd "wl-paste --type image --watch cliphist store"

    # Desactivamos efectos visuales usando hyprctl
    hyprctl --batch "\
        keyword general:gaps_in 0; \
        keyword general:gaps_out 0; \
        keyword general:border_size 1; \
        keyword decoration:rounding 0; \
        keyword decoration:blur:enabled false; \
        keyword decoration:drop_shadow false; \
        keyword animations:enabled false"

    # Creamos el archivo de estado
    touch "$STATE_FILE"
fi
