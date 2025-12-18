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
    can_reboot=1  # Flag para controlar si proceder al reinicio

    # Comprobar si el dispositivo aparece en /proc/swaps; si no, no es necesario swapoff
    echo "[1/6] Comprobando /proc/swaps para ${ZRAM_DEV}..."
    if su -c "grep -q \"${ZRAM_DEV}\" /proc/swaps" 2>/dev/null; then
        echo "  Entrada de swap encontrada para ${ZRAM_DEV}; intentando desactivar (reintentos)..."
        swap_off_success=0
        for i in 1 2 3 4 5; do
            err_out=$(su -c "swapoff ${ZRAM_DEV}" 2>&1) || true
            if [ -z "${err_out}" ]; then
                swap_off_success=1
                break
            fi
            echo "  swapoff falló, intento ${i}/5: ${err_out} - intentando resetear zram y esperar 1s..."
            su -c "echo 1 > ${ZRAM_SYS}/reset" 2>/dev/null || true
            sleep 1
        done

        # Si sigue presente en /proc/swaps, intentar desactivar otras entradas individualmente
        if su -c "grep -q \"${ZRAM_DEV}\" /proc/swaps" 2>/dev/null; then
            echo "  La entrada de ${ZRAM_DEV} sigue en /proc/swaps tras intentos; desactivando entradas listadas en /proc/swaps..."
            swaps_list=$(awk 'NR>1 {print $1}' /proc/swaps 2>/dev/null || true)
            if [ -z "${swaps_list}" ]; then
                echo "    No se encontraron entradas en /proc/swaps o no pudo leerse el archivo."
            else
                for sdev in ${swaps_list}; do
                    echo "    Intentando swapoff para ${sdev} (3 reintentos)..."
                    sw_ok=0
                    for try in 1 2 3; do
                        err_out=$(su -c "swapoff ${sdev}" 2>&1) || true
                        if [ -z "${err_out}" ]; then
                            sw_ok=1
                            break
                        fi
                        echo "      swapoff ${sdev} falló (intento ${try}/3): ${err_out}"
                        if echo "${sdev}" | grep -q zram; then
                            sname=$(basename "${sdev}")
                            su -c "echo 1 > /sys/block/${sname}/reset" 2>/dev/null || true
                            echo "      Reseteado ${sname}, esperando 1s..."
                        fi
                        sleep 1
                    done
                    if [ "${sw_ok}" -ne 1 ]; then
                        echo "      No fue posible desactivar swap en ${sdev}; recolectando diagnósticos y abortando reinicio."
                        can_reboot=0
                        LOG="/data/local/tmp/RamOpt.log"
                        ts=$(date '+%F %T')
                        su -c "sh -c 'echo "=== ${ts} - swapoff FAILED for ${sdev}" >> ${LOG}'" 2>/dev/null || true
                        su -c "sh -c 'echo "error: ${err_out}" >> ${LOG}'" 2>/dev/null || true
                        su -c "sh -c 'cat /proc/swaps >> ${LOG} 2>/dev/null'" 2>/dev/null || true
                        su -c "sh -c 'ls -la /sys/block/zram0/ >> ${LOG} 2>/dev/null'" 2>/dev/null || true
                        su -c "sh -c 'dmesg | tail -n 50 >> ${LOG} 2>/dev/null'" 2>/dev/null || true
                        su -c "sh -c 'grep -H "${sdev}" /proc/*/fd 2>/dev/null | sed -n "1,100p" >> ${LOG}'" 2>/dev/null || true
                        echo "      Diagnóstico guardado en ${LOG}."
                    fi
                done
            fi
        else
            echo "  swapoff OK (entrada removida de /proc/swaps)."
        fi
    else
        echo "  No hay entrada de swap para ${ZRAM_DEV} en /proc/swaps; omitiendo swapoff."
    fi
                    fi

                    sleep 1
                done

                if [ "${sw_ok}" -ne 1 ]; then
                    echo "      Aviso: No fue posible desactivar swap en ${sdev}. Recolectando diagnósticos..."
                    can_reboot=0  # Marcar que no se puede reiniciar
                    # Volcar diagnósticos útiles al log
                    LOG="/data/local/tmp/RamOpt.log"
                    ts=$(date '+%F %T')
                    su -c "sh -c 'echo "=== ${ts} - swapoff FAILED for ${sdev}" >> ${LOG}'" 2>/dev/null || true
                    su -c "sh -c 'echo "error: ${err_out}" >> ${LOG}'" 2>/dev/null || true
                    su -c "sh -c 'echo "contents of /proc/swaps:" >> ${LOG}'" 2>/dev/null || true
                    su -c "sh -c 'cat /proc/swaps >> ${LOG} 2>/dev/null'" 2>/dev/null || true
                    su -c "sh -c 'echo \"ls /sys/block/zram0/ \(files\):\" >> ${LOG}'" 2>/dev/null || true
                    su -c "sh -c 'ls -la /sys/block/zram0/ >> ${LOG} 2>/dev/null'" 2>/dev/null || true
                    su -c "sh -c 'echo "dmesg tail:" >> ${LOG}'" 2>/dev/null || true
                    su -c "sh -c 'dmesg | tail -n 50 >> ${LOG} 2>/dev/null'" 2>/dev/null || true
                    su -c "sh -c 'echo "open fds referencing ${sdev}:" >> ${LOG}'" 2>/dev/null || true
                    su -c "sh -c 'grep -H "${sdev}" /proc/*/fd 2>/dev/null | sed -n "1,100p" >> ${LOG}'" 2>/dev/null || true

                    echo "      Ver diagnóstico escrito en ${LOG}. Puedes pegar su contenido si quieres ayuda." 
                fi
            done
        fi
    else
        echo "  swapoff OK (o no había swap activo)."
    fi

    echo "[2/6] Intentando poner el tamaño de disco de zram a 0 (reintentos)..."
    disksize_ok=0
    for i in 1 2 3 4 5; do
        # Intentar setear a 0 directamente
        if su -c "echo 0 > ${ZRAM_SYS}/disksize" 2>/dev/null; then
            disksize_ok=1
            break
        fi
        # Si falla, resetear y esperar
        su -c "echo 1 > ${ZRAM_SYS}/reset" 2>/dev/null || true
        sleep 1
        # Intentar de nuevo después de reset
        if su -c "echo 0 > ${ZRAM_SYS}/disksize" 2>/dev/null; then
            disksize_ok=1
            break
        fi
        echo "  Falló setear disksize a 0, intento ${i}/5..."
        sleep 1
    done

    if [ "$disksize_ok" -eq 0 ]; then
        echo "  Advertencia: No se pudo setear disksize a 0 directamente, pero verificaremos el estado final."
    fi

    # Verificaciones finales
    disksize_val=$(su -c "cat ${ZRAM_SYS}/disksize" 2>/dev/null || echo "missing")
    if [ "${disksize_val}" = "0" ] || [ "${disksize_val}" = "missing" ]; then
        echo "  Dispositivo zram en 0B o inexistente: ${disksize_val}. Intentando remover módulo para eliminación completa..."
        su -c "rmmod zram" 2>/dev/null && echo "  Módulo zram removido exitosamente." || echo "  No se pudo remover módulo zram (puede estar en uso)."
        # Verificar si se eliminó
        disksize_val=$(su -c "cat ${ZRAM_SYS}/disksize" 2>/dev/null || echo "missing")
        if [ "${disksize_val}" = "missing" ]; then
            echo "  Dispositivo zram eliminado completamente."
        else
            echo "  Dispositivo zram aún presente (disksize: ${disksize_val})."
        fi
    else
        echo "  Dispositivo zram aún activo (disksize: ${disksize_val}). Intentando reset y rmmod..."
        su -c "echo 1 > ${ZRAM_SYS}/reset" 2>/dev/null || true
        sleep 1
        su -c "rmmod zram" 2>/dev/null && echo "  Módulo zram removido después de reset." || echo "  No se pudo remover módulo zram."
        disksize_val=$(su -c "cat ${ZRAM_SYS}/disksize" 2>/dev/null || echo "missing")
        if [ "${disksize_val}" = "missing" ]; then
            echo "  Dispositivo zram eliminado."
        else
            echo "  Error: No se pudo eliminar zram completamente. Abortando reinicio."
            can_reboot=0
        fi
    fi

    # Ajustes de memoria a valores de fábrica
    su -c 'sysctl -w vm.swappiness=60'
    su -c 'sysctl -w vm.dirty_background_ratio=10'
    su -c 'sysctl -w vm.dirty_ratio=20'
    su -c 'sysctl -w vm.vfs_cache_pressure=100'
    su -c 'sysctl -w vm.min_free_kbytes=65536'
    if [ -f /proc/sys/vm/nr_hugepages ]; then
        su -c 'echo 0 > /proc/sys/vm/nr_hugepages' 2>/dev/null
    fi

    echo "[3/6] Verificando valores restaurados:"
    echo "vm.swappiness: $(su -c 'cat /proc/sys/vm/swappiness')"
    echo "vm.dirty_background_ratio: $(su -c 'cat /proc/sys/vm/dirty_background_ratio')"
    echo "vm.dirty_ratio: $(su -c 'cat /proc/sys/vm/dirty_ratio')"
    echo "vm.vfs_cache_pressure: $(su -c 'cat /proc/sys/vm/vfs_cache_pressure')"
    echo "vm.min_free_kbytes: $(su -c 'cat /proc/sys/vm/min_free_kbytes')"
    echo "nr_hugepages: $(su -c 'cat /proc/sys/vm/nr_hugepages' 2>/dev/null || echo 'N/A')"

    if [ "$can_reboot" -eq 1 ]; then
        echo "[4/6] Esperando 3 segundos antes de reiniciar..."
        sleep 3
        echo "[5/6] Reiniciando el dispositivo..."
        su -c 'reboot'
    else
        echo "[4/6] Reinicio abortado debido a fallos en la eliminación de swap/zram. Verifica el log en /data/local/tmp/RamOpt.log para más detalles."
    fi

else
    echo "Opción no válida. Saliendo."
    exit 1
fi

echo "Proceso completado con éxito."