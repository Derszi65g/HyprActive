# HyprActive

Una configuración de Hyprland altamente personalizada y dinámica, centrada en la automatización de temas y la eficiencia del flujo de trabajo.

# Screenshots

<details><summary><h2>Escritorio</h2></summary>

![](/assets/screenshot-desktop.png)

</details><br>

<details><summary><h2>Lanzador de Aplicaciones (Rofi)</h2></summary>

![](/assets/screenshot-rofi-launcher.png)

</details><br>

<details><summary><h2>Selector de Fondos de Pantalla</h2></summary>

![](/assets/screenshot-wallselector.png)

</details><br>

<details><summary><h2>Menú de Apagado (Rofi)</h2></summary>

![](/assets/screenshot-powermenu.png)

</details><br>

<details><summary><h2>Modo Juego</h2></summary>

![](/assets/screenshot-gaming-mode.png)

</details><br>

# Características Principales

*   **Theming Dinámico con `hellwal`**: Cambia el esquema de colores de todo el sistema al instante basándose en tu fondo de pantalla. Afecta a:
    *   **Hyprland**: Colores de los bordes de las ventanas.
    *   **Waybar**: Barra de estado completamente temática.
    *   **Rofi**: Menús consistentes con el esquema de color.
    *   **Dunst**: Notificaciones que coinciden con tu tema.
    *   **Kitty**: Terminal a juego.
*   **Selector de Fondos de Pantalla Avanzado**: Un script de Rofi para previsualizar y seleccionar fondos de pantalla, aplicando el nuevo tema sobre la marcha.
*   **Modo de Juego**: Optimiza el rendimiento con un solo atajo de teclado, desactivando animaciones, Waybar, Dunst y otros procesos para una experiencia de juego sin distracciones.
*   **Gestor de Portapapeles Integrado**: Accede y gestiona tu historial del portapapeles (texto e imágenes) a través de una interfaz de Rofi, con soporte para favoritos.
*   **Scripts de Rofi Personalizados**:
    *   Lanzador de aplicaciones con el fondo de pantalla actual.
    *   Menú de apagado, reinicio y suspensión.
    *   Selector de Emojis.
*   **Waybar Completa**: Muestra espacios de trabajo, uso de CPU/memoria, brillo, volumen, estado de la batería y bandeja del sistema.

# Dependencias

Para que esta configuración funcione correctamente, necesitarás instalar el siguiente software:

*   **Compositor y Shell**: `hyprland`, `kitty`
*   **Barra de Estado**: `waybar`
*   **Lanzador y Menús**: `rofi`
*   **Gestor de Fondos y Theming**: `swww`, `hellwal-git` (desde AUR)
*   **Notificaciones**: `dunst`
*   **Capturas de Pantalla**: `grim`, `slurp`
*   **Portapapeles**: `wl-paste`, `cliphist`
*   **Utilidades del Sistema**: `thunar`, `brightnessctl`, `pactl`, `zenity`, `power-profiles-daemon`, `wlr-randr`
*   **Fuentes**: Se recomienda una fuente Nerd Font (ej. `ttf-jetbrains-mono-nerd`).

# Instalación

1.  **Clona el repositorio:**
    ```bash
    git clone https://github.com/Derszi65g/HyprActive.git ~/.config/hypr
    ```
2.  **Instala las dependencias:**
    Usa tu gestor de paquetes para instalar todas las dependencias listadas arriba. `hellwal-git` debe ser instalado desde AUR.

    **Ejemplo en Arch Linux:**
    ```bash
    # Instalar dependencias desde los repositorios oficiales
    sudo pacman -S hyprland kitty waybar rofi swww dunst grim slurp wl-paste cliphist thunar brightnessctl pactl zenity power-profiles-daemon ttf-jetbrains-mono-nerd wlr-randr

    # Instalar un ayudante de AUR como paru (si no lo tienes)
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru

    # Instalar hellwal-git usando paru
    paru -S hellwal
    ```
3.  **Crea los directorios necesarios:**
    ```bash
    mkdir -p ~/screenshots
    mkdir -p ~/wallhypr
    ```
    Coloca tus fondos de pantalla en `~/wallhypr`.

4.  **¡Reinicia Hyprland y disfruta!**

# Atajos de Teclado

## Gestión de Ventanas y Espacios de Trabajo

| Teclas                                       | Acción                                           |
| :------------------------------------------- | :----------------------------------------------- |
| <kbd>Super</kbd> + <kbd>Q</kbd>               | Cerrar la ventana activa                         |
| <kbd>Super</kbd> + <kbd>F</kbd>               | Activar/Desactivar pantalla completa             |
| <kbd>Super</kbd> + <kbd>Espacio</kbd>         | Cambiar el foco a la última ventana activa       |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Espacio</kbd> | Hacer la ventana flotante / en mosaico           |
| <kbd>Super</kbd> + <kbd>H</kbd>/<kbd>J</kbd>/<kbd>K</kbd>/<kbd>L</kbd> | Mover el foco de la ventana (estilo Vim)         |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd>/<kbd>J</kbd>/<kbd>K</kbd>/<kbd>L</kbd> | Mover la ventana activa (estilo Vim)             |
| <kbd>Super</kbd> + <kbd>1-9</kbd>, <kbd>0</kbd>, <kbd>D</kbd> | Cambiar al espacio de trabajo correspondiente    |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1-9</kbd>, <kbd>0</kbd>, <kbd>D</kbd> | Mover la ventana al espacio de trabajo           |
| <kbd>Super</kbd> + <kbd>R</kbd>               | Entrar en modo de redimensionar ventana (usa flechas/Vim) |

## Aplicaciones y Scripts

| Teclas                                       | Acción                                           |
| :------------------------------------------- | :----------------------------------------------- |
| <kbd>Super</kbd> + <kbd>Enter</kbd>           | Abrir terminal (`kitty`)                         |
| <kbd>Super</kbd> + <kbd>A</kbd>               | Lanzador de aplicaciones Rofi                    |
| <kbd>Super</kbd> + <kbd>E</kbd>               | Abrir gestor de archivos (`thunar`)              |
| <kbd>Super</kbd> + <kbd>Tab</kbd>             | Menú de apagado Rofi                             |
| <kbd>Super</kbd> + <kbd>W</kbd>               | Selector de fondos de pantalla (tema oscuro)     |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd> | Selector de fondos de pantalla (tema claro)      |
| <kbd>Super</kbd> + <kbd>S</kbd>               | Activar/Desactivar Modo de Juego                 |
| <kbd>Super</kbd> + <kbd>V</kbd>               | Menú principal del gestor de portapapeles        |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | Ver historial del portapapeles                 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd> | Recargar la configuración de Hyprland            |

## Capturas de Pantalla

| Teclas                                       | Acción (Guardado en Portapapeles)                |
| :------------------------------------------- | :----------------------------------------------- |
| <kbd>Print</kbd>                             | Pantalla completa                                |
| <kbd>Super</kbd> + <kbd>Print</kbd>           | Ventana activa                                   |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd> | Selección de área                                |
| **Teclas**                                   | **Acción (Guardado en `~/screenshots`)**         |
| <kbd>Ctrl</kbd> + <kbd>Print</kbd>            | Pantalla completa                                |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Print</kbd> | Ventana activa                                   |
| <kbd>Shift</kbd> + <kbd>Print</kbd>           | Selección de área                                |

## Controles del Sistema

| Teclas                                       | Acción                                           |
| :------------------------------------------- | :----------------------------------------------- |
| <kbd>XF86MonBrightnessUp</kbd>/<kbd>Down</kbd> | Ajustar brillo                                   |
| <kbd>XF86AudioRaiseVolume</kbd>/<kbd>Lower</kbd>/<kbd>Mute</kbd> | Ajustar volumen                                  |
