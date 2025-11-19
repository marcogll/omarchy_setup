# 🚀 Omarchy Setup Script v3.0.0

Script de instalación y configuración **modular** para **Arch Linux / Omarchy** con menú interactivo.

## 🎯 Características Principales

- **✅ Estructura Modular**: Scripts independientes para cada componente
- **🎨 Menú Interactivo**: Selecciona qué instalar según tus necesidades
- **🌀 Progreso Limpio**: Las tareas en background muestran el estado sin invadir los prompts interactivos
- **🔐 Sesión Sudo Persistente**: Reutiliza la contraseña durante toda la ejecución para evitar interrupciones
- **🔧 Fácil de Extender**: Agrega nuevos módulos fácilmente

## ⚡ Instalación rápida

```bash
# Clonar el repositorio
git clone https://github.com/marcogll/omarchy_setup.git
cd omarchy_setup

# Ejecutar el script maestro
./omarchy-setup.sh
```

## 📦 Estructura Modular

```
omarchy_zsh_setup/
├── omarchy-setup.sh          # Script maestro con menú interactivo
├── modules/
│   ├── common.sh              # Funciones comunes (colores, logging, etc.)
│   ├── apps.sh                # Instalación de aplicaciones
│   ├── zsh-config.sh          # Configuración de Zsh
│   ├── docker.sh              # Docker y Portainer
│   ├── zerotier.sh            # ZeroTier VPN
│   ├── printer.sh             # Configuración de impresoras (CUPS)
│   ├── mouse_cursor.sh        # Tema de cursor Bibata
│   ├── icon_manager.sh        # Gestor de temas de iconos
│   ├── ssh-keyring.sh         # Sincronización de claves SSH con GNOME Keyring
│   ├── davinci-resolve.sh     # DaVinci Resolve (Intel Edition)
└── Readme.md
```

## 🎮 Uso del Menú Interactivo

Al ejecutar `./omarchy-setup.sh`, verás un menú con las siguientes opciones:

```
╔════════════════════════════════════════════════════════════╗
║  🌀 Omarchy Setup Script — Configuración Modular          ║
╚════════════════════════════════════════════════════════════╝

Selecciona las opciones que deseas instalar:

  1) 📦 Instalar Aplicaciones (VS Code, VLC, drivers, etc.)
  2) 🐚 Configurar Zsh (shell, plugins, config)
  3) 🐳 Instalar Docker y Portainer
  4) 🌐 Instalar ZeroTier VPN
  5) 🖨️  Configurar Impresoras (CUPS)
  6) 🖱️ Instalar Tema de Cursor (Bibata)
  7) 🎨 Gestionar Temas de Iconos (Papirus, Tela, etc.)
  K) 🔐 Sincronizar claves SSH con GNOME Keyring
  F) 💾 Habilitar Formatos FAT/exFAT/NTFS/ext4
  H) 🎨 Instalar Configuración de Hyprland
  R) 🎬 Instalar DaVinci Resolve (Intel Edition)
  A) ✅ Instalar Todo (opciones 1, 2, K, 3, 4, 5, 6, 7, F, H)
  0) 🚪 Salir
```

> ℹ️ **Nota:** La opción `A) Instalar Todo` ejecuta los módulos 1, 2, K, 3, 4, 5, 6, 7, F y H. DaVinci Resolve (`R`) no se incluye aquí; instálalo manualmente cuando ya tengas el ZIP en `~/Downloads/`.

> 🌀 **Progreso limpio:** Los módulos en background informan su avance sin animaciones invasivas; toda la salida detallada se imprime limpia y se escribe en `./logs/`.

## 📋 Módulos Disponibles

A continuación se detalla lo que hace cada módulo. Para una descripción técnica completa, consulta la [**DOCUMENTACION.md**](./DOCUMENTACION.md).

- **`1) 📦 Instalar Aplicaciones`**: Instala un conjunto completo de software esencial, incluyendo herramientas de desarrollo (`python`, `nodejs`, `nvm`, `brew`), aplicaciones multimedia (`VLC`, `Audacity`), drivers optimizados para gráficos Intel Iris Xe y herramientas de gestión de energía como `tlp`. También configura servicios clave del sistema.

- **`2) 🐚 Configurar Zsh`**: Transforma tu terminal. Instala `Zsh`, el gestor de plugins `Oh My Zsh`, y el prompt visual `Oh My Posh` con el tema Catppuccin. Añade autocompletado, resaltado de sintaxis, una útil función de ayuda (`zsh_help`), y lo establece como tu shell por defecto.

- **`3) 🐳 Instalar Docker y Portainer`**: Prepara tu sistema para el desarrollo con contenedores. Instala `Docker` y `Docker Compose`, configura los servicios necesarios y, opcionalmente, despliega `Portainer`, una interfaz web para gestionar tus contenedores fácilmente.

- **`4) 🌐 Instalar ZeroTier VPN`**: Instala el cliente de la VPN `ZeroTier`, una forma sencilla de crear redes virtuales seguras. El módulo te guiará para unirte a una red si lo deseas.

- **`5) 🖨️ Configurar Impresoras (CUPS)`**: Instala el sistema de impresión de Linux (`CUPS`) y añade drivers para impresoras, con soporte especial para modelos Epson.

- **`6) 🖱️ Instalar Tema de Cursor (Bibata)`**: Mejora la apariencia de tu escritorio instalando el popular tema de cursores Bibata, dándole un aspecto moderno y pulido.

- **`7) 🎨 Gestionar Temas de Iconos`**: Te permite instalar y cambiar entre diferentes temas de iconos para personalizar la apariencia de tus aplicaciones y carpetas (incluye Papirus, Tela, etc.).

- **`K) 🔐 Sincronizar claves SSH con GNOME Keyring`**: Guarda de forma segura las contraseñas de tus claves SSH. Después de introducir la contraseña una vez, el sistema la recordará por ti, facilitando las conexiones a servidores remotos.

- **`F) 💾 Habilitar Formatos de Disco`**: Añade soporte para que tu sistema pueda leer y escribir en discos duros y memorias USB formateadas con sistemas de archivos de otros sistemas operativos como `NTFS` (Windows) o `exFAT`.

- **`H) 🎨 Instalar Configuración de Hyprland`**: Instala y configura el gestor de ventanas `Hyprland` y todas las herramientas necesarias para un entorno de escritorio *tiling* completo y funcional (`waybar`, `wofi`, `kitty`, etc.).

- **`R) 🎬 Instalar DaVinci Resolve`**: Automatiza la compleja instalación del editor de vídeo profesional DaVinci Resolve. **Nota:** Requiere que descargues el instalador `.zip` oficial manualmente en tu carpeta de `~/Downloads`.

---
## 📚 Documentación Técnica

Para una descripción detallada de la implementación de cada módulo, las funciones que utiliza y las configuraciones específicas que aplica, por favor consulta el archivo [**DOCUMENTACION.md**](./DOCUMENTACION.md).

Este documento es ideal para desarrolladores que deseen extender la funcionalidad del script o para usuarios avanzados que quieran entender a fondo su funcionamiento.
---

## 🔧 Ejecutar Módulos Individualmente

Cada módulo puede ejecutarse de forma independiente si lo necesitas:

```bash
./modules/apps.sh
./modules/docker.sh
# etc.
```

---

## 🔄 Después de la instalación

### 1. Reiniciar sesión o terminal (IMPORTANTE)

Para que todos los cambios surtan efecto (nuevo shell, permisos de `docker`, variables de entorno), es fundamental que **cierres sesión y vuelvas a iniciarla** o reinicies el sistema.

### 2. Verificar la instalación

Una vez que hayas vuelto a iniciar sesión, abre una terminal y comprueba que todo funciona como esperas:
```bash
# Verifica que tu shell es Zsh y el prompt se ve bien
echo $SHELL

# Comprueba que Docker funciona sin sudo
docker ps

# Lista tus claves SSH gestionadas por el agente
ssh-add -l
```

---

## 🛠️ Solución de problemas

### El prompt de Zsh se ve con caracteres extraños (▯, ?, etc.)

Esto ocurre porque no tienes instalada una **Nerd Font**, que contiene los iconos que usa el prompt.

1.  **Instala una Nerd Font.** El propio `oh-my-posh` puede hacerlo por ti:
    ```bash
    oh-my-posh font install meslo
    ```
2.  **Configura tu terminal.** Abre las preferencias de tu emulador de terminal (GNOME Terminal, Konsole, Kitty, etc.) y cambia la fuente del perfil a la que acabas de instalar (ej. `MesloLGM Nerd Font`).

### Docker no funciona sin `sudo`

Asegúrate de haber **cerrado sesión y vuelto a iniciarla** después de ejecutar el módulo de Docker. Si el problema persiste, verifica que tu usuario pertenece al grupo `docker` con el comando `groups`.

---
## 🔧 Agregar Nuevos Módulos

La estructura modular facilita la adición de nueva funcionalidad.

1.  Crea un nuevo script en la carpeta `modules/`. Sigue la plantilla de los módulos existentes.
2.  Añade una entrada para tu nuevo módulo en el array `MODULES` dentro de `omarchy-setup.sh`.
3.  ¡Listo! Tu módulo aparecerá en el menú principal.

Para más detalles, consulta la [guía para contribuidores](./.docs/AGENTS.md).

---

## 📝 Changelog

### v3.0.0
- ✨ **Reestructuración completa a un sistema modular.**
-  interactive menu para seleccionar componentes.
- 📜 **Añadida documentación técnica** (`DOCUMENTACION.md`) y guía para contribuidores (`AGENTS.md`).
- 🎨 **Interfaz de usuario mejorada** con logs claros y un indicador de progreso.
- 🔧 **Módulos actualizados** y separados por funcionalidad.

---

## 📄 Licencia

MIT License - Libre de usar y modificar

---

## 👤 Autor

**Marco**
- GitHub: [@marcogll](https://github.com/marcogll)
- Repo: [scripts_mg](https://github.com/marcogll/scripts_mg)

---


```bash
# Instalar en una línea
bash <(curl -fsSL https://raw.githubusercontent.com/marcogll/scripts_mg/main/omarchy_zsh_setup/omarchy-setup.sh)
```

## 📝 Notas importantes

- **Shell por defecto**: El módulo de Zsh modifica `.bashrc` para que las terminales nuevas usen Zsh.

## 🚀 Próximos Pasos

1. Ejecuta `./omarchy-setup.sh` para ver el menú interactivo
2. Selecciona los módulos que deseas instalar
3. Revisa los mensajes durante la instalación
4. Reinicia o cierra sesión después de instalar servicios
5. Disfruta de tu configuración personalizada

---

🚀 **¡Disfruta tu nuevo setup modular de Omarchy!**
