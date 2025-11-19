# AGENTS.md - Guía para Contribuidores y Tareas Pendientes

Este documento está destinado a los desarrolladores (humanos o agentes de IA) que trabajan en el proyecto Omarchy Setup. Contiene un resumen del estado actual, una lista de tareas pendientes y directrices para el desarrollo futuro.

## Análisis del Proyecto

El proyecto "Omarchy Setup" es un script de post-instalación para Arch Linux, diseñado con un enfoque en la modularidad y la facilidad de uso.

- **Orquestador Principal (`omarchy-setup.sh`):** Actúa como el punto de entrada. Presenta un menú interactivo al usuario, gestiona las sesiones de `sudo`, y coordina la ejecución de los diferentes módulos.
- **Módulos (`modules/`):** Cada archivo `.sh` en este directorio encapsula una funcionalidad específica (ej. instalar aplicaciones, configurar Docker, personalizar Zsh). Esta estructura facilita la adición o modificación de tareas sin afectar al resto del sistema.
- **Funciones Comunes (`modules/common.sh`):** Centraliza el código repetitivo, como las funciones de logging, la instalación de paquetes (pacman y AUR), y la creación de backups. Esto promueve la reutilización de código y la consistencia.
- **Interactividad:** El sistema está diseñado para ser interactivo, solicitando confirmación del usuario para acciones importantes, pero también soporta ejecuciones en segundo plano para tareas no interactivas.

## Tareas Pendientes y Mejoras

A continuación se detallan las tareas prioritarias para mejorar la funcionalidad y robustez del proyecto.

### 1. Implementar un Sistema de Dependencias entre Módulos

- **Objetivo:** Evitar fallos cuando un módulo requiere que otro se haya ejecutado previamente (por ejemplo, `ssh-keyring.sh` necesita que `apps.sh` instale `gnome-keyring`).
- **Acción Propuesta:**
    1.  En cada módulo, definir un array o variable que liste sus dependencias. Ejemplo en `ssh-keyring.sh`: `MODULE_DEPS=("apps")`.
    2.  En `omarchy-setup.sh`, antes de ejecutar un módulo, leer esta variable y comprobar si los módulos dependientes ya han sido ejecutados (se podría mantener un registro de módulos completados).
    3.  Si una dependencia no se ha cumplido, informar al usuario y ofrecerle ejecutarla primero.

### 2. Crear un Archivo de Configuración Central (`omarchy.conf`)

- **Objetivo:** Facilitar instalaciones desatendidas y permitir a los usuarios pre-configurar sus preferencias sin modificar los scripts.
- **Acción Propuesta:**
    1.  Crear un archivo `omarchy.conf.example` con pares clave-valor para las opciones personalizables (ej. `INSTALL_DOCKER="true"`, `ZEROTIER_NETWORK_ID="tu_id_de_red"`).
    2.  En `omarchy-setup.sh`, comprobar si existe `omarchy.conf` y cargarlo.
    3.  Modificar los módulos para que lean estas variables de configuración y actúen en consecuencia, saltándose las preguntas interactivas si la opción está definida.

### 3. Añadir Funcionalidad de Desinstalación / Reversión

- **Objetivo:** Permitir a los usuarios deshacer los cambios realizados por un módulo de forma segura.
- **Acción Propuesta:**
    1.  Para cada módulo, crear una función `uninstall_<nombre_modulo>`.
    2.  Esta función debe realizar la acción inversa a la instalación: eliminar paquetes, restaurar archivos de configuración a partir de los backups `.bak` y deshabilitar los servicios correspondientes.
    3.  Añadir una nueva opción en el menú principal para acceder a un sub-menú de desinstalación.

### 4. Implementar Verificaciones Post-Instalación

- **Objetivo:** Aumentar la fiabilidad del script confirmando que el software principal de cada módulo se ha instalado y funciona correctamente.
- **Acción Propuesta:**
    1.  Al final de cada módulo, añadir una pequeña función de `verify_<nombre_modulo>`.
    2.  Esta función debería ejecutar un comando simple para comprobar el estado del software. Ejemplos:
        - **Docker:** `docker --version` y `docker run hello-world`.
        - **Zsh:** `zsh --version` y comprobar que `oh-my-posh` está en el `$PATH`.
        - **ZeroTier:** `sudo zerotier-cli status`.
    3.  Informar al usuario si la verificación ha sido exitosa o ha fallado.

## Directrices para Futuros Desarrollos

- **Modularidad:** Toda nueva funcionalidad debe encapsularse en su propio módulo.
- **Idempotencia:** Los scripts deben poder ejecutarse múltiples veces sin causar efectos secundarios negativos. Comprueba siempre si un paquete ya está instalado o si una configuración ya existe antes de aplicarla.
- **Lenguaje y Estilo:** Todo el código y los comentarios deben estar en **español** para mantener la consistencia del proyecto.
- **Manejo de Errores:** Utiliza las funciones `log_error`, `log_warning` y `log_success` de `common.sh` para proporcionar feedback claro al usuario. Si un comando crítico falla, el script debe salir de forma controlada.
- **Seguridad:** No almacenes información sensible (contraseñas, claves de API) directamente en los scripts. Utiliza ficheros locales como `.zshrc.local` (que está en `.gitignore`) para estos casos.
