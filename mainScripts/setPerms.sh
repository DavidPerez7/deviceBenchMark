#!/data/data/com.termux/files/usr/bin/bash

# Otorga permisos de ejecución a los scripts principales

chmod +x "$(dirname "$0")/battery.sh"
chmod +x "$(dirname "$0")/setOpt.sh"

echo "Permisos de ejecución otorgados a battery.sh y setOpt.sh."
