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
    echo "[1/6] Restaurando valores de fábrica..."

    ZRAM_DEV="/dev/block/zram0"
    ZRAM_SYS="/sys/block/zram0"

    echo "[1/6] Intentando desactivar swap en ${ZRAM_DEV} (reintentos)..."
    swap_off_success=0
    for i in 1 2 3 4 5; do
        if su -c "swapoff ${ZRAM_DEV}" 2>/dev/null; then
            swap_off_success=1
            break
        fi
        echo "  swapoff falló, intento ${i}/5 - intentando resetear zram y esperar 1s..."
        su -c "echo 1 > ${ZRAM_SYS}/reset" 2>/dev/null || true
        sleep 1
    done

    # Comprobar si la entrada de swap sigue en /proc/swaps
    if su -c "grep -q \"${ZRAM_DEV}\" /proc/swaps" 2>/dev/null; then
        echo "  Atención: la entrada de swap para ${ZRAM_DEV} sigue presente en /proc/swaps. Intentando desactivar cada entrada de swap..."

        # Leer las entradas de /proc/swaps (omitimos la cabecera)
        swaps_list=$(awk 'NR>1 {print $1}' /proc/swaps 2>/dev/null || true)
        if [ -z "${swaps_list}" ]; then
            echo "    No se encontraron entradas en /proc/swaps o no pudo leerse el archivo."
        else
            for sdev in ${swaps_list}; do
                echo "    Intentando swapoff para ${sdev} (reintentos)..."
                sw_ok=0
                for try in 1 2 3; do
                    if su -c "swapoff ${sdev}" 2>/dev/null; then
                        echo "      swapoff ${sdev} OK"
                        sw_ok=1
                        break
                    fi
                    echo "      swapoff ${sdev} falló (intento ${try}/3). Intentando reset si es zram y esperando 1s..."
                    if echo "${sdev}" | grep -q zram; then
                        sname=$(basename "${sdev}")
                        su -c "echo 1 > /sys/block/${sname}/reset" 2>/dev/null || true
                    fi
                    sleep 1
                done
                if [ "${sw_ok}" -ne 1 ]; then
                    echo "      Aviso: No fue posible desactivar swap en ${sdev}. Puede recrearse al reiniciar."
                fi
            done
        fi
    else
        echo "  swapoff OK (o no había swap activo)."
    fi

    echo "[2/6] Intentando poner el tamaño de disco de zram a 0 (reintentos)..."
    disksize_ok=0
    for i in 1 2 3; do
        if su -c "echo 0 > ${ZRAM_SYS}/disksize" 2>/dev/null; then
            disksize_ok=1
            break
        fi
        echo "  Falló setear disksize a 0, intento ${i}/3..."
        sleep 1
    done

    # Verificaciones finales
    disksize_val=$(su -c "cat ${ZRAM_SYS}/disksize" 2>/dev/null || echo "missing")
    if [ "${disksize_val}" = "0" ] || [ "${disksize_val}" = "missing" ]; then
        echo "  Dispositivo zram ahora en 0B (o innexistente): ${disksize_val}"
    else
        echo "  No se consiguió dejar disksize a 0 (valor: ${disksize_val}). Intentando remover el módulo zram si está cargado..."
        # Intentar quitar el módulo zram (si lsmod/rmmod están disponibles)
        if su -c "lsmod 2>/dev/null | grep -q zram" 2>/dev/null; then
            su -c "rmmod zram" 2>/dev/null && echo "  Módulo zram removido." || echo "  No fue posible remover el módulo zram.";
        else
            echo "  lsmod no disponible o zram no aparece en lsmod; no se intentó rmmod."
        fi

        disksize_val=$(su -c "cat ${ZRAM_SYS}/disksize" 2>/dev/null || echo "missing")
        if [ "${disksize_val}" != "0" ] && [ "${disksize_val}" != "missing" ]; then
            echo "  Advertencia: No se pudo eliminar completamente zram. Está en ${disksize_val} bytes; puede ser recreado por el sistema al reiniciar. No se abortará el reinicio para evitar dejar el dispositivo en estado incierto."
        fi
    fi

    # Ajustes de memoria a valores de fábrica
    su -c 'sysctl -w vm.swappiness=60'
    su -c 'sysctl -w vm.dirty_background_ratio=10'
    su -c 'sysctl -w vm.dirty_ratio=20'
    su -c 'sysctl -w vm.vfs_cache_pressure=100'
    su -c 'sysctl -w vm.min_free_kbytes=65536'
    su -c 'echo 0 > /proc/sys/vm/nr_hugepages' 2>/dev/null

    echo "[3/6] Verificando valores restaurados:"
    echo "vm.swappiness: $(su -c 'cat /proc/sys/vm/swappiness')"
    echo "vm.dirty_background_ratio: $(su -c 'cat /proc/sys/vm/dirty_background_ratio')"
    echo "vm.dirty_ratio: $(su -c 'cat /proc/sys/vm/dirty_ratio')"
    echo "vm.vfs_cache_pressure: $(su -c 'cat /proc/sys/vm/vfs_cache_pressure')"
    echo "vm.min_free_kbytes: $(su -c 'cat /proc/sys/vm/min_free_kbytes')"
    echo "nr_hugepages: $(su -c 'cat /proc/sys/vm/nr_hugepages')"

    echo "[4/6] Esperando 3 segundos antes de reiniciar..."
    sleep 3
    echo "[5/6] Reiniciando el dispositivo..."
    su -c 'reboot'

else
    echo "Opción no válida. Saliendo."
    exit 1
fi

echo "Proceso completado con éxito."