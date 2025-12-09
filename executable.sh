#!/data/data/com.termux/files/usr/bin/bash

# Otorga permisos de ejecución a los scripts principales
echo '= OTORGANDO PERMISOS DE EJECUCION ='
DIR=$(pwd)
chmod +x "$DIR/scripts/battery.sh"
chmod +x "$DIR/scripts/setopt.sh"
echo "Permisos de ejecución otorgados (battery.sh, setopt.sh)."

declare opcion
echo "Seleccione una opción:"
echo "1. Ejecutar analisis de batería"
echo "2. Configurar optimizaciones de CPU y GPU"
read opcion

if [ "$opcion" -eq 1 ]; then
    # Ejecuta el script de análisis de batería
    su -c "/data/data/com.termux/files/usr/bin/bash \"$DIR/scripts/battery.sh\""
    exit 0
fi

if [ "$opcion" -eq 2 ]; then
    # Ejecuta el script de configuración de optimizaciones
    su -c "/data/data/com.termux/files/usr/bin/bash \"$DIR/scripts/setopt.sh\""
    exit 0
fi
