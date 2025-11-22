#!/data/data/com.termux/files/usr/bin/bash

# Otorga permisos de ejecución a los scripts principales
echo '= OTORGANDO PERMISOS DE EJECUCION ='
chmod +x "$(dirname "$0")/battery.sh"
chmod +x "$(dirname "$0")/setOpt.sh"
echo "Permisos de ejecución otorgados (battery.sh, setOpt.sh)."

declare opcion
echo "Seleccione una opción:"
echo "1. Ejecutar analisis de batería"
echo "2. Configurar optimizaciones de CPU y GPU"
read opcion

if [ "$opcion" -eq 1 ]; then
    # Ejecuta el script de análisis de batería
    su -c "/data/data/com.termux/files/usr/bin/bash /data/data/com.termux/files/home/BatteryOpt/mainScripts/battery.sh"
    exit 0
fi

if [ "$opcion" -eq 2 ]; then
    # Ejecuta el script de configuración de optimizaciones
    su -c "/data/data/com.termux/files/usr/bin/bash /data/data/com.termux/files/home/BatteryOpt/mainScripts/setOpt.sh"
    exit 0
fi
