#!/bin/bash

# --- CONFIGURACIÓN ---
CONFIG_DIR="$HOME/.config/hypr/source"
CONFIG_FILE="$CONFIG_DIR/monitor.conf"

# --- VERIFICACIONES INICIALES ---
if ! command -v wlr-randr &> /dev/null || ! command -v hyprctl &> /dev/null; then
    echo "Error: wlr-randr o hyprctl no están instalados. Por favor, instálalos para continuar."
    exit 1
fi

# --- FASE 1: DETECCIÓN Y PREPARACIÓN ---
WLR_OUTPUT=$(wlr-randr)
mapfile -t MONITOR_NAMES < <(hyprctl monitors | grep 'Monitor' | awk '{print $2}')

if [ ${#MONITOR_NAMES[@]} -eq 0 ]; then
    echo "Error: No se pudo detectar ningún monitor activo con hyprctl."
    exit 1
fi

declare -a final_config_lines=()
declare -a configured_monitors=()
monitor_count=${#MONITOR_NAMES[@]}
current_monitor_index=1

# --- FASE 2: BUCLE PRINCIPAL DE CONFIGURACIÓN ---
for monitor_name in "${MONITOR_NAMES[@]}"; do
    echo "======================================================="
    echo "Configurando Monitor $current_monitor_index de $monitor_count: $monitor_name"
    echo "======================================================="

    # --- ANÁLISIS DEL MONITOR ACTUAL (VERSIÓN CORREGIDA Y ROBUSTA) ---
    MAX_RES=$(echo "$WLR_OUTPUT" | awk -v monitor="$monitor_name" '
        BEGIN { max_pixels = 0; max_res = "" }
        $1 == monitor { in_monitor_block = 1 }
        in_monitor_block {
            if ($1 ~ /^[0-9]+x[0-9]+$/) {
                split($1, dim, "x");
                width = dim[1]; height = dim[2]; pixels = width * height;
                if (pixels > max_pixels) { max_pixels = pixels; max_res = $1; }
            }
            if ($0 ~ /^$/) { in_monitor_block = 0 }
        }
        END { print max_res }
    ')

    # Comprobación de seguridad
    if [ -z "$MAX_RES" ]; then
        echo "Error crítico: No se pudo determinar la resolución nativa para $monitor_name. Abortando."
        exit 1
    fi

    MAX_WIDTH=$(echo "$MAX_RES" | cut -d'x' -f1)
    MAX_HEIGHT=$(echo "$MAX_RES" | cut -d'x' -f2)
    MAX_REFRESH_RATE=$(echo "$WLR_OUTPUT" | awk -v m="$monitor_name" -v r="$MAX_RES" '$1==m{b=1}b&&$1==r{for(i=2;i<=NF;++i)if($i~/^[0-9.]+$/)print int($i)}b&&/^$/{b=0}' | sort -rn | head -n1)
    [ -z "$MAX_REFRESH_RATE" ] && MAX_REFRESH_RATE=60

    echo "Resolución nativa detectada: ${MAX_RES}"
    echo "Tasa de refresco máxima detectada: ${MAX_REFRESH_RATE}Hz"
    echo "----------------------------------------"

    # --- PASO 1: RESOLUCIÓN ---
    declare -a resolutions=("3840x2160" "2560x1440" "1920x1080" "1600x900" "1366x768" "1280x720" "1152x648" "1024x576" "960x540" "854x480" "3440x1440" "2560x1080" "2560x1600" "1920x1200" "1680x1050" "1440x900" "1280x800" "1600x1200" "1400x1050" "1280x960" "1024x768" "800x600" "1280x1024")
    filtered_resolutions=()
    for res in "${resolutions[@]}"; do
        w=$(echo "$res" | cut -d'x' -f1); h=$(echo "$res" | cut -d'x' -f2)
        if [ "$w" -le "$MAX_WIDTH" ] && [ "$h" -le "$MAX_HEIGHT" ] && ! [[ " ${filtered_resolutions[*]} " =~ " $res " ]]; then filtered_resolutions+=("$res"); fi
    done
    if ! [[ " ${filtered_resolutions[*]} " =~ " $MAX_RES " ]]; then filtered_resolutions=("$MAX_RES" "${filtered_resolutions[@]}"); fi

    filtered_resolutions+=("Personalizada" "Salir")
    echo "Paso 1: Selecciona una resolución para $monitor_name"
    PS3="Elige una resolución: "
    select selected_res in "${filtered_resolutions[@]}"; do
        case $selected_res in
            "Personalizada") read -p "Introduce resolución personalizada: " custom_res; if [[ "$custom_res" =~ ^[0-9]+x[0-9]+$ ]]; then selected_res=$custom_res; break; else echo "Formato inválido."; fi;;
            "Salir") echo "Operación cancelada."; exit 0;;
            *) if [[ " ${filtered_resolutions[*]} " =~ " $selected_res " ]]; then break; else echo "Opción inválida."; fi;;
        esac
    done

    # --- PASO 2: TASA DE REFRESCO ---
    declare -a all_refresh_rates=(360 240 165 144 120 100 75 60 50 30 24)
    filtered_refresh_rates=(); for r in "${all_refresh_rates[@]}"; do if [ "$r" -le "$MAX_REFRESH_RATE" ]; then filtered_refresh_rates+=("$r"); fi; done
    refresh_rate_options=("${filtered_refresh_rates[@]}")
    refresh_rate_options+=("Personalizada" "auto" "Salir")
    echo "Paso 2: Selecciona una tasa de refresco para $monitor_name"
    PS3="Elige una tasa (Hz): "
    select choice in "${refresh_rate_options[@]}"; do
        case $choice in
            "Personalizada") read -p "Introduce tasa personalizada: " custom_rate; if [[ "$custom_rate" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then selected_refresh_rate=$custom_rate; break; else echo "Formato inválido."; fi;;
            "auto") selected_refresh_rate=""; break;;
            "Salir") echo "Operación cancelada."; exit 0;;
            *) if [[ " ${refresh_rate_options[*]} " =~ " $choice " ]]; then selected_refresh_rate=$choice; break; else echo "Opción inválida."; fi;;
        esac
    done

    # --- PASO 3: ESCALA (DPI) ---
    declare -a scale_options=("auto" "1.0 (Nativa)" "1.25" "1.5" "2.0" "0.8" "Personalizado" "Salir")
    echo "Paso 3: Selecciona un factor de escala (DPI) para $monitor_name"
    PS3="Elige una escala: "
    select choice in "${scale_options[@]}"; do
        case $choice in
            "auto") selected_scale="auto"; break;;
            "Personalizado") read -p "Introduce escala personalizada: " custom_scale; if [[ "$custom_scale" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then selected_scale=$custom_scale; break; else echo "Formato inválido."; fi;;
            "Salir") echo "Operación cancelada."; exit 0;;
            *) selected_scale=$(echo "$choice"|awk '{print $1}'); break;;
        esac
    done

    # --- PASO 4: POSICIÓN (CONDICIONAL) ---
    position_string="auto"
    if [ ${#configured_monitors[@]} -gt 0 ]; then
        position_options=()
        for ref_monitor in "${configured_monitors[@]}"; do
            position_options+=("A la derecha de $ref_monitor")
            position_options+=("A la izquierda de $ref_monitor")
            position_options+=("Encima de $ref_monitor")
            position_options+=("Debajo de $ref_monitor")
        done
        position_options+=("auto (por defecto)" "Salir")
        echo "Paso 4: Selecciona la posición de $monitor_name"
        PS3="Elige posición relativa: "
        select choice in "${position_options[@]}"; do
            case $choice in
                "auto (por defecto)") position_string="auto"; break;;
                "Salir") echo "Operación cancelada."; exit 0;;
                "") echo "Opción inválida.";;
                *) 
                    relation=$(echo "$choice" | awk '{print $3}')
                    ref_mon=$(echo "$choice" | awk '{print $5}')
                    case $relation in
                        derecha) hypr_relation="rightof";;
                        izquierda) hypr_relation="leftof";;
                        Encima) hypr_relation="above";;
                        Debajo) hypr_relation="below";;
                    esac
                    position_string="${hypr_relation},${ref_mon}"
                    break
                    ;;
            esac
        done
    fi

    # --- CONSTRUIR Y GUARDAR LA LÍNEA DE CONFIGURACIÓN ---
    res_hz=$selected_res
    [ -n "$selected_refresh_rate" ] && res_hz="${selected_res}@${selected_refresh_rate}"
    final_line="monitor=$monitor_name,${res_hz},${position_string},${selected_scale}"
    final_config_lines+=("$final_line")
    configured_monitors+=("$monitor_name")
    ((current_monitor_index++))
done

# --- FASE 3: ESCRITURA FINAL ---
if [ ${#final_config_lines[@]} -gt 0 ]; then
    echo "======================================================="
    echo "Configuración completa. Escribiendo en $CONFIG_FILE..."
    mkdir -p "$CONFIG_DIR"
    {
        echo "# Configuración de monitores generada automáticamente"
        printf "%s\n" "${final_config_lines[@]}"
    } > "$CONFIG_FILE"
    echo ""
    echo "Contenido final del archivo:"
    cat "$CONFIG_FILE"
    echo ""
    echo "¡Listo! Recarga la configuración de Hyprland para aplicar los cambios."
else
    echo "No se generó ninguna configuración. Saliendo."
fi