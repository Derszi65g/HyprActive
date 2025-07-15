#!/usr/bin/env bash
set -o pipefail

ROFI_THEME="$HOME/.config/rofi/themes/clipboard.rasi"
CLIPHIST_FAVS="$HOME/.cache/cliphist_favs"

copy_clip() {
    cliphist decode "$1" | wl-copy -t "$(cliphist decode "$1" | file -b --mime-type -)"
}

generate_menu() {
    paste <(cliphist list --ids) <(cliphist list) | awk -F'\t' '{
        gsub(/\n|\r/, " ", $2);
        if ($2 ~ /^\[image\//) {
            # CAMBIO: Usamos un nombre de icono de Papirus para imágenes
            printf "%s: %s\0icon\x1fimage-x-generic-symbolic\n", $1, $2
        } else {
            # CAMBIO: Usamos un nombre de icono de Papirus para texto
            printf "%s: %s\0icon\x1ftext-x-generic-symbolic\n", $1, $2
        }
    }'
}

show_history() {
    local selection
    selection=$(generate_menu | rofi -dmenu -i -p "Historial" -theme "$ROFI_THEME")

    if [[ -n "$selection" ]]; then
        local sel_id="${selection%%:*}"
        copy_clip "$sel_id"
    fi
}

view_favorites() {
    touch "$CLIPHIST_FAVS"

    local action
    # CAMBIO: Usamos nombres de iconos de Papirus para las opciones de favoritos
    action=$(printf "Ver Favoritos\0icon\x1fstarred-symbolic\nAgregar Favorito\0icon\x1flist-add-symbolic\nEliminar Favorito\0icon\x1flist-remove-symbolic" | rofi -dmenu -p "Favoritos" -theme "$ROFI_THEME")

    case "$action" in
        "Ver Favoritos")
            if [[ ! -s "$CLIPHIST_FAVS" ]]; then
                rofi -e "No hay favoritos guardados." -theme "$ROFI_THEME"
                return
            fi

            local fav_menu_str=""
            while IFS= read -r id; do
                local preview
                preview=$(cliphist list | awk -v id_search="$id" 'BEGIN{RS="\n"; ORS=" "} $0 ~ "^"id_search"\t" {sub("^"id_search"\t", ""); print; exit}')

                if [[ -z "$preview" ]]; then
                    preview="[Contenido no encontrado en el historial actual]"
                fi

                local icon="text-x-generic-symbolic"
                if [[ "$preview" == *"[image/"* ]]; then
                    icon="image-x-generic-symbolic"
                fi
                fav_menu_str+="$(printf "%s: %s\0icon\x1f%s\n" "$id" "$preview" "$icon")"
            done < <(tac "$CLIPHIST_FAVS")

            local sel
            sel=$(echo -e "$fav_menu_str" | rofi -dmenu -p "Favoritos" -theme "$ROFI_THEME")

            if [[ -n "$sel" ]]; then
                copy_clip "${sel%%:*}"
            fi
            ;;

        "Agregar Favorito")
            local selection
            selection=$(generate_menu | rofi -dmenu -p "Selecciona para agregar" -theme "$ROFI_THEME")

            if [[ -n "$selection" ]]; then
                local id_to_add="${selection%%:*}"
                if ! grep -q "^${id_to_add}$" "$CLIPHIST_FAVS"; then
                    echo "$id_to_add" >> "$CLIPHIST_FAVS"
                    rofi -e "Agregado a favoritos." -theme "$ROFI_THEME"
                else
                    rofi -e "Este elemento ya está en favoritos." -theme "$ROFI_THEME"
                fi
            fi
            ;;

        "Eliminar Favorito")
            if [[ ! -s "$CLIPHIST_FAVS" ]]; then
                rofi -e "No hay favoritos para eliminar." -theme "$ROFI_THEME"
                return
            fi

            local fav_to_del_menu_str=""
            while IFS= read -r id; do
                 local preview
                 preview=$(cliphist list | awk -v id_search="$id" 'BEGIN{RS="\n"; ORS=" "} $0 ~ "^"id_search"\t" {sub("^"id_search"\t", ""); print; exit}')
                 local icon="text-x-generic-symbolic"
                 if [[ "$preview" == *"[image/"* ]]; then
                    icon="image-x-generic-symbolic"
                 fi
                 fav_to_del_menu_str+="$(printf "%s: %s\0icon\x1f%s\n" "$id" "$preview" "$icon")"
            done < "$CLIPHIST_FAVS"

            local sel
            sel=$(echo -e "$fav_to_del_menu_str" | rofi -dmenu -p "Selecciona para eliminar" -theme "$ROFI_THEME")

            if [[ -n "$sel" ]]; then
                local sel_id="${sel%%:*}"
                grep -v "^$sel_id$" "$CLIPHIST_FAVS" > "${CLIPHIST_FAVS}.tmp" && mv "${CLIPHIST_FAVS}.tmp" "$CLIPHIST_FAVS"
                rofi -e "Favorito eliminado." -theme "$ROFI_THEME"
            fi
            ;;
    esac
}

delete_items() {
    local selections
    selections=$(generate_menu | rofi -dmenu -multi-select -p "Eliminar (selección múltiple)" -theme "$ROFI_THEME")

    if [[ -n "$selections" ]]; then
        echo "$selections" | while IFS= read -r item; do
            echo "${item%%:*}"
        done | cliphist delete
        rofi -e "Elementos eliminados." -theme "$ROFI_THEME"
    fi
}

clear_history() {
    local confirm
    confirm=$(printf "No\nSí" | rofi -dmenu -i -p "¿Limpiar TODO el historial?" -theme "$ROFI_THEME")
    if [[ "$confirm" == "Sí" ]]; then
        cliphist wipe
        rofi -e "Historial limpiado." -theme "$ROFI_THEME"
    fi
}

main_action=${1:-menu}

case "$main_action" in
    menu)
        # CAMBIO: Usamos nombres de iconos de Papirus para el menú principal
        options="Historial\0icon\x1fedit-paste-symbolic\nFavoritos\0icon\x1fstarred-symbolic\nEliminar del historial\0icon\x1fedit-delete-symbolic\nLimpiar todo\0icon\x1fedit-clear-all-symbolic"
        choice=$(echo -e "$options" | rofi -dmenu -i -p "Gestor de Portapapeles" -theme "$ROFI_THEME")

        case "$choice" in
            "Historial")              show_history ;;
            "Favoritos")              view_favorites ;;
            "Eliminar del historial") delete_items ;;
            "Limpiar todo")           clear_history ;;
        esac
        ;;
    -H|--historial) show_history ;;
    -F|--favoritos) view_favorites ;;
    -D|--delete)    delete_items ;;
    -C|--clear)     clear_history ;;
    *)
        cliphist list | rofi -dmenu -i -p "Clipboard" -theme "$ROFI_THEME" | cliphist decode | wl-copy
        ;;
esac
