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

    # EJECUTAR DIAGNÓSTICOS para ayudar a identificar quién crea/activa zram en el arranque
    echo "[DIAGNÓSTICO] Buscando referencias a zram/swapon/mkswap en rutas comunes (puede tardar)..."
    su -c 'grep -R --line-number "zram\|swapon\|mkswap" /init* /system /vendor /data /etc 2>/dev/null | sed -n "1,200p" || echo "(no se encontraron referencias o faltan permisos)"'

    echo "[DIAGNÓSTICO] dmesg -> últimas entradas relacionadas (zram/swap)..."
    su -c 'dmesg | egrep -i "zram|swap|swapon|mkswap" | tail -n 200 || echo "(sin coincidencias en dmesg)"'

    echo "[DIAGNÓSTICO] logcat -> últimas entradas relacionadas (si disponible)..."
    su -c 'logcat -d | egrep -i "zram|swap|swapon|mkswap" | sed -n "1,200p" 2>/dev/null || echo "(logcat no disponible o sin coincidencias)"'
# Comprobación adicional para detectar apps que gestionan zram (ej: ExKernelManager)
echo "[DIAGNÓSTICO] Buscando paquetes y procesos sospechosos (ExKernelManager/"exkernel")..."
su -c 'pm list packages | egrep "flar2.exkernelmanager|exkernel" 2>/dev/null || echo "(paquete no encontrado)"'
su -c 'pm path flar2.exkernelmanager 2>/dev/null || true'
su -c 'ps -A 2>/dev/null | egrep "exkernel|flar2" || true'
su -c 'logcat -d | egrep -i "exkernel|flar2|exkernelmanager" | sed -n "1,200p" 2>/dev/null || true'
    echo "[DIAGNÓSTICO] /proc/swaps, /sys/block/zram0 y procesos relacionados:"
    su -c 'cat /proc/swaps 2>/dev/null || echo "(no se pudo leer /proc/swaps)"'
    su -c 'ls -la /sys/block | grep zram || echo "(no existe /sys/block/zram*)"'
    su -c 'cat /sys/block/zram0/disksize 2>/dev/null || echo "(no existe /sys/block/zram0/disksize)"'
    su -c 'cat /sys/block/zram0/mem_used_total 2>/dev/null || echo "(no existe /sys/block/zram0/mem_used_total)"'
    su -c 'ps -A 2>/dev/null | egrep "zram|zramctl|swap|swapon" || echo "(sin procesos evidentes relacionados)"'

    echo "[DIAGNÓSTICO] Búsqueda de ficheros/scripts que contengan 'zram' (resultados limitados)..."
    su -c 'grep -R --line-number "zram" /init* /system /vendor /data /etc 2>/dev/null | sed -n "1,200p" || echo "(no se encontraron archivos que contengan 'zram' en rutas comunes)"'

    echo "[DIAGNÓSTICO] FIN. Copia y pega este bloque para analizar quién recrea zram en el reinicio."

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
            swaps_list=$(su -c "awk 'NR>1 {print \$1}' /proc/swaps 2>/dev/null || true")
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
                        ts=$(date '+%F %T')
                        echo "\n===== DIAGNÓSTICO ${ts} - swapoff FAILED for ${sdev} ====="
                        echo "error: ${err_out}"
                        echo "--- /proc/swaps (privileged) ---"
                        su -c 'cat /proc/swaps' 2>/dev/null || echo "(no se pudo leer /proc/swaps)"
                        echo "--- /sys/block/zram0/ ---"
                        su -c 'ls -la /sys/block/zram0/' 2>/dev/null || echo "(no se pudo listar /sys/block/zram0)"
                        echo "--- dmesg (tail 50) ---"
                        su -c 'dmesg | tail -n 50' 2>/dev/null || echo "(no se pudo leer dmesg)"
                        echo "--- Open fds referencing ${sdev} ---"
                        su -c "sh -c 'grep -H \"${sdev}\" /proc/*/fd 2>/dev/null | sed -n \"1,200p\"'" 2>/dev/null || echo "(no se encontraron fds)"
                        echo "===== FIN DIAGNÓSTICO =====\n"
                    fi
                done
            fi
        else
            echo "  swapoff OK (entrada removida de /proc/swaps)."
        fi
    else
        echo "  No hay entrada de swap para ${ZRAM_DEV} en /proc/swaps; omitiendo swapoff."
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
        echo "  Dispositivo zram en 0B o inexistente: ${disksize_val}. Intentando remover módulo para eliminación completa..."        echo "  Nota: para modo no interactivo y forzar terminación, exporta: FORCE_ZRAM=1 antes de ejecutar el script"        # Intentar remover el módulo zram
        if su -c "rmmod zram" 2>/dev/null; then
            echo "  Módulo zram removido exitosamente."
        else
            echo "  No se pudo remover módulo zram directamente (posiblemente en uso o integrado en el kernel). Ejecutando diagnósticos adicionales..."
            echo "  --- /proc/modules (zram) ---"
            su -c 'grep -w "zram" /proc/modules 2>/dev/null || true' || true
            echo "  --- /sys/module/zram (exists?) ---"
            su -c 'ls -la /sys/module/zram 2>/dev/null || true' || true

            # Intentar modprobe -r si está disponible
            removed=0
            if command -v modprobe >/dev/null 2>&1; then
                echo "  Intentando modprobe -r zram..."
                if su -c "modprobe -r zram" 2>/dev/null; then
                    echo "  modprobe -r funcionó."
                    removed=1
                else
                    echo "  modprobe -r falló o no es aplicable."
                fi
            fi

            # Intentar rmmod -f si está disponible (con advertencia)
            if [ "$removed" -ne 1 ]; then
                if command -v rmmod >/dev/null 2>&1 && rmmod -? 2>&1 | grep -q -- "-f"; then
                    echo "  Intentando rmmod -f zram (FORZAR, puede ser peligroso)..."
                    if su -c "rmmod -f zram" 2>/dev/null; then
                        echo "  rmmod -f funcionó."
                        removed=1
                    else
                        echo "  rmmod -f falló o no está permitido por el kernel."
                    fi
                fi
            fi

            # Si aún no se removió, buscar procesos que mantengan fds y ofrecer terminarlos
            if [ "$removed" -ne 1 ]; then
                holders=$(su -c "grep -H -- \"${ZRAM_DEV}\" /proc/*/fd 2>/dev/null || true")
                if [ -n "${holders}" ]; then
                    echo "  Procesos con fds abiertos al dispositivo (muestra limitada):"
                    su -c "grep -H -- \"${ZRAM_DEV}\" /proc/*/fd 2>/dev/null | sed -n '1,200p'"
                    pids=$(su -c "grep -H -- \"${ZRAM_DEV}\" /proc/*/fd 2>/dev/null | awk -F'/' '{print \\$3}' | sort -u" 2>/dev/null || true)
                    for pid in ${pids}; do
                        cmdline=$(su -c "tr '\0' ' ' < /proc/${pid}/cmdline 2>/dev/null || echo '[no access]'" 2>/dev/null || echo '[no access]')
                        echo "    PID: ${pid} - CMD: ${cmdline}"
                    done

                    # Soportar modo forzado no interactivo con variable de entorno FORCE_ZRAM=1
                    if [ "${FORCE_ZRAM}" = "1" ]; then
                        echo "  FORCE_ZRAM=1: terminando procesos automáticamente..."
                        kill_ans=y
                    else
                        read -p "  ¿Terminar estos procesos ahora? [y/N]: " kill_ans
                    fi

                    if [ "${kill_ans}" = "y" ] || [ "${kill_ans}" = "Y" ]; then
                        for pid in ${pids}; do
                            echo "    Enviando SIGTERM a ${pid}..."
                            su -c "kill -15 ${pid}" 2>/dev/null || true
                        done
                        sleep 2
                        if su -c "rmmod zram" 2>/dev/null; then
                            echo "  Módulo zram removido tras terminar procesos."
                            removed=1
                        else
                            echo "  Aún no se pudo remover zram. Aplicando SIGKILL a los PIDs listados..."
                            for pid in ${pids}; do
                                echo "    Enviando SIGKILL a ${pid}..."
                                su -c "kill -9 ${pid}" 2>/dev/null || true
                            done
                            sleep 1
                            if su -c "rmmod zram" 2>/dev/null; then
                                echo "  Módulo zram removido tras SIGKILL."
                                removed=1
                            else
                                echo "  No fue posible remover zram incluso tras SIGKILL."
                            fi
                        fi
                    else
                        echo "  No se terminaron procesos. No se intentará forzar eliminación del módulo."
                    fi
                else
                    echo "  No se encontraron procesos que referencien ${ZRAM_DEV}, y los intentos de rmmod/modprobe fallaron."
                fi
            fi

            # Estado final y recomendaciones
            echo "  --- Estado final / comprobaciones ---"
            su -c 'cat /sys/block/zram0/disksize 2>/dev/null || echo "(no existe /sys/block/zram0/disksize)"'
            su -c 'cat /sys/block/zram0/mem_used_total 2>/dev/null || echo "(no existe /sys/block/zram0/mem_used_total)"'
            echo "  /proc/modules (zram):"
            su -c 'grep -w "zram" /proc/modules 2>/dev/null || echo "(zram no presente en /proc/modules)"'

            if [ "$removed" -ne 1 ]; then
                echo "  Aviso: No fue posible eliminar el módulo zram. Si /sys/block/zram0 existe y su disksize=0, el dispositivo está neutralizado y es seguro continuar." 
                echo "  Si deseas eliminarlo completamente, puede ser necesario: 1) identificar y cerrar procesos que lo usan, 2) usar rmmod -f (si tu kernel lo permite), o 3) recompilar/desactivar zram en el kernel/boot."
            fi
        fi
        # Verificar si disksize es 0 (dispositivo neutralizado, suficiente para reinicio)
        disksize_val=$(su -c "cat ${ZRAM_SYS}/disksize" 2>/dev/null || echo "missing")
        if [ "${disksize_val}" = "0" ] || [ "${disksize_val}" = "missing" ]; then
            echo "  Dispositivo zram neutralizado (disksize: ${disksize_val}). Permitiendo reinicio."
        else
            echo "  Error: disksize sigue en ${disksize_val}. No se pudo neutralizar zram. Abortando reinicio."
            can_reboot=0
        fi
    else
        echo "  Dispositivo zram aún activo (disksize: ${disksize_val}). Intentando reset y rmmod..."
        su -c "echo 1 > ${ZRAM_SYS}/reset" 2>/dev/null || true
        sleep 1
        su -c "rmmod zram" 2>/dev/null && echo "  Módulo zram removido después de reset." || echo "  No se pudo remover módulo zram."
        disksize_val=$(su -c "cat ${ZRAM_SYS}/disksize" 2>/dev/null || echo "missing")
        if [ "${disksize_val}" = "0" ] || [ "${disksize_val}" = "missing" ]; then
            echo "  Dispositivo zram neutralizado (disksize: ${disksize_val}). Permitiendo reinicio."
        else
            echo "  Error: disksize sigue en ${disksize_val}. No se pudo neutralizar zram. Abortando reinicio."
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
        echo "[4/6] Reinicio abortado debido a fallos en la eliminación de swap/zram. Diagnósticos ya mostrados arriba."
    fi

else
    echo "Opción no válida. Saliendo."
    exit 1
fi

echo "Proceso completado con éxito."