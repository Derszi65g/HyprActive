# HyprActive

Una configuración de Hyprland altamente personalizada y dinámica, centrada en la automatización de temas y la eficiencia del flujo de trabajo.

# Screenshots

## Escritorio

![](/assets/screenshot-desktop.png)

## Lanzador de Aplicaciones (Rofi)

![](/assets/screenshot-rofi-launcher.png)

## Selector de Fondos de Pantalla

![](/assets/screenshot-wallselector.png)

## Menú de Apagado (Rofi)

![](/assets/screenshot-powermenu.png)

## Modo Juego

![](/assets/screenshot-gaming-mode.png)

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

Para que esta configuración funcione correctamente, necesitarás instalar los siguientes paquetes. El script de instalación (`install.sh`) está diseñado para manejarlos automáticamente usando `paru`.

*   **Entorno de Escritorio**:
    *   `hyprland`: El compositor de Wayland.
    *   `xdg-desktop-portal-hyprland`: Portal de escritorio para integración de aplicaciones.
*   **Terminal y Shell**:
    *   `kitty`: Emulador de terminal acelerado por GPU.
*   **Interfaz de Usuario**:
    *   `waybar`: Barra de estado altamente personalizable.
    *   `rofi`: Lanzador de aplicaciones y menús.
    *   `dunst`: Demonio de notificaciones.
*   **Theming y Visuales**:
    *   `swww`: Gestor de fondos de pantalla para Wayland.
    *   `hellwal`: Herramienta para generar esquemas de color desde el fondo de pantalla (AUR).
    *   `ttf-jetbrains-mono-nerd`: Fuente con iconos (Nerd Font).
*   **Utilidades del Sistema**:
    *   `thunar`: Gestor de archivos.
    *   `brightnessctl`: Control del brillo de la pantalla.
    *   `libpulse`: Proporciona `pactl` para el control del volumen.
    *   `power-profiles-daemon`: Gestión de perfiles de energía.
    *   `zenity`: Creación de diálogos gráficos simples.
*   **Capturas y Portapapeles**:
    *   `grim`: Herramienta para capturas de pantalla en Wayland.
    *   `slurp`: Utilidad para seleccionar regiones en Wayland.
    *   `wl-clipboard`: Proporciona `wl-paste` y `wl-copy` para el portapapeles.
    *   `cliphist`: Historial del portapapeles para Wayland.
*   **Herramientas Adicionales**:
    *   `jq`: Procesador de JSON de línea de comandos.
    *   `wlr-randr`: Herramienta para configurar salidas (monitores) en wlroots.

# Instalación

Este repositorio incluye un script de instalación automática que se encarga de todo el proceso: comprobar dependencias, copiarlas y configurar los monitores y el fondo de pantalla inicial.

**Requisitos:**
*   Una distribución basada en Arch Linux.
*   Conexión a internet.
*   Se recomienda tener un ayudante de AUR como `paru` o `yay` instalado para las dependencias de AUR. El script puede intentar instalar `paru` si no lo encuentra.

## Instalación Automática (Recomendado)

1.  **Clona el repositorio:**
    ```bash
    git clone https://github.com/Derszi65g/HyprActive.git
    ```

2.  **Ejecuta el script de instalación:**
    ```bash
    cd HyprActive
    chmod +x install.sh
    ./install.sh
    ```
    El script te guiará a través de la instalación de dependencias y la configuración de tus monitores.

3.  **Coloca tus fondos de pantalla** en la carpeta `~/wallhypr` que el script creará por ti.

4.  **¡Reinicia Hyprland y disfruta!**

## Instalación Manual

Si prefieres hacerlo manualmente, sigue estos pasos:

1.  **Instala las dependencias:**
    Asegúrate de tener todas las dependencias de la [lista principal](#dependencias) instaladas.

    **Ejemplo en Arch Linux:**
    ```bash
    # Instalar dependencias desde los repositorios oficiales
    sudo pacman -S hyprland kitty waybar rofi swww dunst grim slurp wl-clipboard cliphist thunar brightnessctl libpulse zenity power-profiles-daemon ttf-jetbrains-mono-nerd wlr-randr jq xdg-desktop-portal-hyprland

    # Instalar un ayudante de AUR (ej. paru) si no lo tienes
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru

    # Instalar dependencias de AUR usando paru
    paru -S hellwal
    ```

2.  **Copia los archivos de configuración:**
    ```bash
    git clone https://github.com/Derszi65g/HyprActive.git
    cp -r HyprActive/.config/* ~/.config/
    ```

3.  **Crea los directorios y copia los fondos:**
    ```bash
    mkdir -p ~/screenshots
    mkdir -p ~/wallhypr
    cp -r HyprActive/wallhypr/* ~/wallhypr/
    ```
4.  **Configura tus monitores** manualmente creando el archivo `~/.config/hypr/source/monitor.conf`.

5.  **Reinicia Hyprland.**

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
