#!/data/data/com.termux/files/usr/bin/bash

# Otorga permisos de ejecución a los scripts principales
echo '= OTORGANDO PERMISOS DE EJECUCION ='
# Determina la ruta absoluta del directorio donde está este script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MAIN_SCRIPTS="$SCRIPT_DIR/mainScripts"

# Archivos a usar
BATTERY="$MAIN_SCRIPTS/battery.sh"
SETOPT="$MAIN_SCRIPTS/setOpt.sh"

if [ -f "$BATTERY" ]; then
    chmod +x "$BATTERY"
else
    echo "Aviso: no se encontró $BATTERY"
fi

if [ -f "$SETOPT" ]; then
    chmod +x "$SETOPT"
else
    echo "Aviso: no se encontró $SETOPT"
fi
echo "Permisos de ejecución otorgados (battery.sh, setOpt.sh)."

declare opcion
echo "Seleccione una opción:"
echo "1. Ejecutar analisis de batería"
echo "2. Configurar optimizaciones de CPU y GPU"
read opcion

if [ "$opcion" -eq 1 ]; then
    # Ejecuta el script de análisis de batería (como root)
    if [ -f "$BATTERY" ]; then
        su -c "bash \"$BATTERY\""
    else
        echo "Error: no se encontró $BATTERY"
        exit 1
    fi
    exit 0
fi

if [ "$opcion" -eq 2 ]; then
    # Ejecuta el script de configuración de optimizaciones (como root)
    if [ -f "$SETOPT" ]; then
        su -c "bash \"$SETOPT\""
    else
        echo "Error: no se encontró $SETOPT"
        exit 1
    fi
    exit 0
fi
