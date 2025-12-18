#!/data/data/com.termux/files/usr/bin/bash

# Script para configurar y optimizar RAM

echo "================================="
echo "== CONFIGURACION DE RAM Y SWAP =="
echo "================================="
sleep 1

declare opcion
echo "Elige una opción:"
echo "1. ⚡ Perfil de Compresión Máxima (Enfoque del Usuario)"
echo "2. 🏎️ Perfil de Procesamiento Directo (Enfoque Recomendado)"
echo "3. 🏁 Restaurar Valores de Fábrica (Neutraliza ZRAM)"
read opcion

if [ "$opcion" -eq 1 ]; then
    echo "[1/4] Activando perfil de compresión máxima..."
    su -c 'swapoff /dev/block/zram0' 2>/dev/null || true
    su -c 'echo 1 > /sys/block/zram0/reset'
    su -c 'echo lz4 > /sys/block/zram0/comp_algorithm'
    su -c 'echo 1610612736 > /sys/block/zram0/disksize'  # 1.5 GB de zram
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
    su -c 'swapoff /dev/block/zram0' 2>/dev/null || true
    su -c 'echo 1 > /sys/block/zram0/reset'

    echo "[2/4] Ajustando parámetros de memoria..."
    su -c 'sysctl -w vm.swappiness=10'
    su -c 'sysctl -w vm.dirty_background_ratio=15'
    su -c 'sysctl -w vm.dirty_ratio=30'
    su -c 'sysctl -w vm.vfs_cache_pressure=50'
    su -c 'sysctl -w vm.min_free_kbytes=65536'

    echo "[3/4] Activando hugepages..."
    su -c 'echo 128 > /proc/sys/vm/nr_hugepages' 2>/dev/null || echo "Hugepages no soportado."

    echo "[4/4] Configuración de procesamiento directo aplicada."

elif [ "$opcion" -eq 3 ]; then
    echo "[1/4] Restaurando valores de fábrica y neutralizando ZRAM..."

    # Neutralizar ZRAM
    echo "[2/4] Desactivando swap si existe..."
    su -c 'swapoff /dev/block/zram0' 2>/dev/null || true
    su -c 'echo 1 > /sys/block/zram0/reset'
    su -c 'echo 0 > /sys/block/zram0/disksize'

    # Ajustes de memoria a valores de fábrica
    su -c 'sysctl -w vm.swappiness=60'
    su -c 'sysctl -w vm.dirty_background_ratio=10'
    su -c 'sysctl -w vm.dirty_ratio=20'
    su -c 'sysctl -w vm.vfs_cache_pressure=100'
    su -c 'sysctl -w vm.min_free_kbytes=65536'
    su -c 'echo 0 > /proc/sys/vm/nr_hugepages' 2>/dev/null || true

    echo "[3/4] Verificando estado final:"
    echo "ZRAM disksize: $(su -c 'cat /sys/block/zram0/disksize' 2>/dev/null || echo 'N/A')"
    echo "Swap activo: $(su -c 'cat /proc/swaps | wc -l') entradas"
    echo "vm.swappiness: $(su -c 'cat /proc/sys/vm/swappiness')"

    echo "[4/4] Valores de fábrica restaurados. ZRAM neutralizado (no se reinicia el dispositivo)."

else
    echo "Opción no válida. Saliendo."
    exit 1
fi

echo "Proceso completado con éxito."