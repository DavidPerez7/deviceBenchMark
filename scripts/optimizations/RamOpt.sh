#!/data/data/com.termux/files/usr/bin/bash

# Script para configurar y optimizar RAM

echo "====================================="
echo "== CONFIGURACION DE RAM Y SWAP =="
echo "====================================="
sleep 1

declare opcion
echo "Elige una opción:"
echo "1. ⚡ Perfil de Compresión Máxima (Enfoque del Usuario)"
echo "2. 🏎️ Perfil de Procesamiento Directo (Enfoque Recomendado)"
echo "3. 🏁 Restaurar Valores de Fábrica y Reiniciar"
read opcion

if [ "$opcion" -eq 1 ]; then
    echo "[1/4] Activando perfil de compresión máxima..."
    su -c 'swapoff /dev/block/zram0' || { echo "Error al desactivar el swap. Intentando forzar..."; su -c 'echo 1 > /sys/block/zram0/reset'; }
    su -c 'echo 1 > /sys/block/zram0/reset'
    su -c 'echo lz4 > /sys/block/zram0/comp_algorithm'
    su -c 'echo 1610612736 > /sys/block/zram0/disksize' # 1.5 GB de zram
    su -c 'mkswap /dev/block/zram0'
    su -c 'swapon /dev/block/zram0'

    echo "[2/4] Ajustando parámetros de memoria..."
    su -c 'sysctl -w vm.swappiness=70'
    su -c 'sysctl -w vm.dirty_background_ratio=5'
    su -c 'sysctl -w vm.dirty_ratio=10'
    su -c 'sysctl -w vm.vfs_cache_pressure=200'
    su -c 'sysctl -w vm.min_free_kbytes=46080'

    echo "[3/4] Configuración de compresión máxima aplicada."

elif [ "$opcion" -eq 2 ]; then
    echo "[1/4] Activando perfil de procesamiento directo..."
    su -c 'swapoff /dev/block/zram0' || { echo "Error al desactivar el swap. Intentando forzar..."; su -c 'echo 1 > /sys/block/zram0/reset'; }
    su -c 'echo 1 > /sys/block/zram0/reset'

    echo "[2/4] Ajustando parámetros de memoria..."
    su -c 'sysctl -w vm.swappiness=10'
    su -c 'sysctl -w vm.dirty_background_ratio=15'
    su -c 'sysctl -w vm.dirty_ratio=30'
    su -c 'sysctl -w vm.vfs_cache_pressure=50'
    su -c 'sysctl -w vm.min_free_kbytes=65536'

    echo "[3/4] Activando hugepages..."
    su -c 'echo 128 > /proc/sys/vm/nr_hugepages' || { echo "Error al configurar hugepages. Verifica el soporte del sistema."; }

    echo "[4/4] Configuración de procesamiento directo aplicada."

elif [ "$opcion" -eq 3 ]; then
    echo "[1/5] Restaurando valores de fábrica..."
    su -c 'swapoff /dev/block/zram0' || { 
        echo "Error al desactivar el swap. Intentando forzar...";
        su -c 'echo 1 > /sys/block/zram0/reset' || { echo "Error crítico: No se pudo resetear zram."; exit 1; }
    }
    su -c 'echo 1 > /sys/block/zram0/reset' || { echo "Error crítico: No se pudo resetear zram."; exit 1; }

    # Eliminar el dispositivo zram completamente
    su -c 'echo 0 > /sys/block/zram0/disksize' || { echo "Error crítico: No se pudo eliminar el dispositivo zram."; exit 1; }

    su -c 'sysctl -w vm.swappiness=60'
    su -c 'sysctl -w vm.dirty_background_ratio=10'
    su -c 'sysctl -w vm.dirty_ratio=20'
    su -c 'sysctl -w vm.vfs_cache_pressure=100'
    su -c 'sysctl -w vm.min_free_kbytes=65536'
    su -c 'echo 0 > /proc/sys/vm/nr_hugepages' 2>/dev/null

    echo "[2/5] Verificando valores restaurados:"
    echo "vm.swappiness: $(su -c 'cat /proc/sys/vm/swappiness')"
    echo "vm.dirty_background_ratio: $(su -c 'cat /proc/sys/vm/dirty_background_ratio')"
    echo "vm.dirty_ratio: $(su -c 'cat /proc/sys/vm/dirty_ratio')"
    echo "vm.vfs_cache_pressure: $(su -c 'cat /proc/sys/vm/vfs_cache_pressure')"
    echo "vm.min_free_kbytes: $(su -c 'cat /proc/sys/vm/min_free_kbytes')"
    echo "nr_hugepages: $(su -c 'cat /proc/sys/vm/nr_hugepages')"

    echo "[3/5] Esperando 3 segundos antes de reiniciar..."
    sleep 3
    echo "[4/5] Reiniciando el dispositivo..."
    su -c 'reboot'

else
    echo "Opción no válida. Saliendo."
    exit 1
fi

echo "Proceso completado con éxito."