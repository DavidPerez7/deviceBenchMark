#!/data/data/com.termux/files/usr/bin/bash

# Configuración rápida de CPU
# CPU 0-3 (cluster 1): powersave, 1363 MHz, 4/4 núcleos
sleep 1
echo "██████╗ ███████╗██████╗ ███╗   ███╗██╗           ██████╗ ██████╗ ████████╗"
echo "██╔══██╗██╔════╝██╔══██╗████╗ ████║██║          ██╔═══██╗██╔══██╗╚══██╔══╝"
echo "██████╔╝█████╗  ██║  ██║██╔████╔██║██║    █████╗██║   ██║██████╔╝   ██║   "
echo "██╔══██╗██╔══╝  ██║  ██║██║╚██╔╝██║██║    ╚════╝██║   ██║██╔═══╝    ██║   "
echo "██║  ██║███████╗██████╔╝██║ ╚═╝ ██║██║          ╚██████╔╝██║        ██║   "
echo "╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝     ╚═╝╚═╝           ╚═════╝ ╚═╝        ╚═╝   "
echo ""
sleep 1
echo "==============================="
echo "VALORES ACTUALES DEL SISTEMA:"
echo "==============================="
echo "Governor CPU0: $(su -c 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')"
echo "Governor CPU4: $(su -c 'cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor')"
echo "Frecuencia mínima CPU0: $(su -c 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq')"
echo "Frecuencia mínima CPU4: $(su -c 'cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq')"
echo "Frecuencia máxima CPU0: $(su -c 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq')"
echo "Frecuencia máxima CPU4: $(su -c 'cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq')"
echo "==============================="
echo "Núcleos activos: $(su -c 'cat /sys/devices/system/cpu/online')"
echo "==============================="
echo "Governor GPU: $(su -c 'cat /sys/class/kgsl/kgsl-3d0/devfreq/governor')"
echo "Frecuencia mínima GPU: $(su -c 'cat /sys/class/kgsl/kgsl-3d0/devfreq/min_freq')"
echo "Frecuencia máxima GPU: $(su -c 'cat /sys/class/kgsl/kgsl-3d0/devfreq/max_freq')"
echo "==============================="
echo "Latencia del scheduler: $(su -c 'sysctl kernel.sched_latency_ns')"
echo "Granularidad mínima del scheduler: $(su -c 'sysctl kernel.sched_min_granularity_ns')"
echo "Granularidad de wakeup del scheduler: $(su -c 'sysctl kernel.sched_wakeup_granularity_ns')"
echo "==============================="
echo "Resolución actual: $(su -c 'wm size')"
echo "DPI actual: $(su -c 'wm density')"
echo "==============================="
echo "Escala de animación de ventana: $(su -c 'settings get global window_animation_scale')"
echo "Escala de animación de transición: $(su -c 'settings get global transition_animation_scale')"
echo "Escala de duración del animador: $(su -c 'settings get global animator_duration_scale')"
echo "==============================="
echo "Daemon termico (Thermal-engine): $(su -c 'pidof thermal-engine')"
# echo "Proteccion termal (Modulo de Kernel Thermal enabled): $(su -c 'cat /sys/module/msm_thermal/parameters/enabled')" NO HAY EN REDMI 7
echo "Limite termal/energetico GPU (Thermal power level): $(su -c 'cat /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel')"
echo "==============================="
echo "Estadísticas de I/O del almacenamiento: $(su -c 'cat /sys/block/mmcblk0/queue/iostats')"
echo "==============================="
echo "CPUs asignados a top-app: $(su -c 'cat /dev/cpuset/top-app/cpus')"
echo "CPUs asignados a background: $(su -c 'cat /dev/cpuset/background/cpus')"
echo "CPUs asignados a system-background: $(su -c 'cat /dev/cpuset/system-background/cpus')"
echo "CPUs asignados a restricted: $(su -c 'cat /dev/cpuset/restricted/cpus')"
echo "CPUs asignados a foreground: $(su -c 'cat /dev/cpuset/foreground/cpus')"
echo "==============================="
echo ""
sleep 1

declare opcion
echo "🚀 Elige un perfil de optimización de CPU para Redmi 7:"
echo ""
echo "1. 🔴 AHORRO EXTREMO (4 núcleos - GPU a 400MHz - resolución 560x1000, 170dpi)"
echo "2. 🟡 AHORRO NORMAL (6 núcleos activos a 1536 y 1401 MHz)"
echo "3. 🟢 RENDIMIENTO MÁXIMO (8 núcleos activos a 1804MHz)"
echo "4. 🔄 VALORES DE FÁBRICA (schedutil, resolución y animaciones predeterminadas)"
echo "5. ⚪ JUEGO (rendimiento equilibrado y eficiencia para juegos)"
echo "6. ⚫ PANTALLA OLED (simular contraste y color tipo OLED)"
echo ""
echo "Ingresa el número de opción (1-6):"
read opcion


sleep 1

# -- PERFIL 1: EXTREMO
if [ "$opcion" -eq 1 ]; then
    echo "Apagando nucleos..."
    sleep 2
    for cpu in 1 2 3; do
        su -c "echo 0 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: offline"
    done
    echo "Configurando cluster 1..."
    sleep 1
    for cpu in 0; do
        su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        su -c "echo conservative > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
        su -c "echo 1363000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
        # Restaurar min_freq real
        min_freq=$(su -c "cat /sys/devices/system/cpu/cpu$cpu/cpufreq/cpuinfo_min_freq")
        su -c "echo $min_freq > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq"

        echo "CPU$cpu: conservative, 1363MHz, online"
    done
    echo "Configurando cluster 2..."
    sleep 1
    for cpu in 4 5 6; do
        su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        su -c "echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
        su -c "echo 1094000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
        # Restaurar min_freq real
        min_freq=$(su -c "cat /sys/devices/system/cpu/cpu$cpu/cpufreq/cpuinfo_min_freq")
        su -c "echo $min_freq > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq"

        echo "CPU$cpu: powersave, 1094MHz, online"
    done

    echo "Configurando GPU..."
    sleep 1
    su -c "echo powersave > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
    sleep 1
    # Setear max_freq si existe
    if su -c "test -e /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"; then
        su -c "echo 400000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"
        sleep 2
    else
        echo "Archivo max_freq no encontrado."
    fi
    # Setear min_freq si existe
    if su -c "test -e /sys/class/kgsl/kgsl-3d0/devfreq/min_freq"; then
        min_gpu_freq=$(su -c "cat /sys/class/kgsl/kgsl-3d0/devfreq/cpuinfo_min_freq" 2>/dev/null)
        if [ -z "$min_gpu_freq" ]; then
            min_gpu_freq=257000000
        fi
        su -c "echo $min_gpu_freq > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq"
        sleep 2
    else
        echo "Archivo min_freq no encontrado."
    fi
    echo "GPU: powersave, 400MHz, configurada con pausas."

    echo "Configurando pantalla... "
    sleep 1
    su -c  wm size 540x1140
    su -c  wm density 200

    echo "Desactivando animaciones..."
    sleep 1
    su -c "settings put global window_animation_scale 0"
    su -c "settings put global transition_animation_scale 0"
    su -c "settings put global animator_duration_scale 0"
    sleep 1
    echo "Configurando ajustes del scheduler para eficiencia..."
    su -c "sysctl -w kernel.sched_latency_ns=12000000"
    su -c "sysctl -w kernel.sched_min_granularity_ns=2500000"
    su -c "sysctl -w kernel.sched_wakeup_granularity_ns=3500000"
    echo "Latencia: 12ms, Granularidad mínima: 2.5ms, Wakeup: 3.5ms configurados."
    sleep 1
    echo "Configurando cpusets para eficiencia..."
    su -c "echo 0-3 > /dev/cpuset/top-app/cpus"
    su -c "echo 0 > /dev/cpuset/background/cpus"
    su -c "echo 0-1 > /dev/cpuset/system-background/cpus"
    su -c "echo 0 > /dev/cpuset/restricted/cpus"
    su -c "echo 0-2 > /dev/cpuset/foreground/cpus"
    echo "Cpusets configurados para eficiencia."
    sleep 1
    echo "Configurando estadísticas de I/O del almacenamiento..."
    su -c "echo 0 > /sys/block/mmcblk0/queue/iostats"
    echo "Estadísticas de I/O desactivadas."
    sleep 1
    echo "== 🔴 AHORRO EXTREMO ACTIVADO 🔴 =="


# -- OPCION 2
elif [ "$opcion" -eq 2 ]; then
    echo "= APAGANDO NUCLEOS ="
    sleep 1
    for cpu in 7; do
        su -c "echo 0 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: offline"
    done
    sleep 1
    echo "= CLUSTER 1 ="
    # Consultar frecuencias disponibles para cluster 1 (CPU 0)
    available_freqs=$(su -c "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies")
    sorted_freqs=$(echo $available_freqs | tr ' ' '\n' | sort -n)
    max_freq_cluster1=$(echo $sorted_freqs | awk '{print $(NF-1)}')  # Segunda más alta
    min_freq_cluster1=$(echo $sorted_freqs | awk '{print $1}')
    for cpu in 0 1 2 3; do
        su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        sleep 1
        su -c "echo conservative > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
        sleep 1
        su -c "echo $max_freq_cluster1 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
        sleep 1
        su -c "echo $min_freq_cluster1 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq"
        sleep 1
        echo "CPU$cpu: conservative, $(($max_freq_cluster1 / 1000))MHz, online"
    done
    echo "= CLUSTER 2 ="
    # Consultar frecuencias disponibles para cluster 2 (CPU 4)
    available_freqs=$(su -c "cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_available_frequencies")
    sorted_freqs=$(echo $available_freqs | tr ' ' '\n' | sort -n)
    max_freq_cluster2=$(echo $sorted_freqs | awk '{print $(NF-1)}')  # Segunda más alta
    min_freq_cluster2=$(echo $sorted_freqs | awk '{print $1}')
    for cpu in 4 5 6; do
        su -c "echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
        sleep 1
        su -c "echo $max_freq_cluster2 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
        sleep 1
        su -c "echo $min_freq_cluster2 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq"
        sleep 1
        echo "CPU$cpu: powersave, $(($max_freq_cluster2 / 1000))MHz, online"
    done
    
    echo "= GPU ="
    sleep 1
    su -c "echo conservative > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
    sleep 1
    # Setear max_freq si existe
    if su -c "test -e /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"; then
        su -c "echo 600000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"
        sleep 1
    fi
    # Setear min_freq si existe
    if su -c "test -e /sys/class/kgsl/kgsl-3d0/devfreq/min_freq"; then
        min_gpu_freq=$(su -c "cat /sys/class/kgsl/kgsl-3d0/devfreq/cpuinfo_min_freq" 2>/dev/null)
        if [ -z "$min_gpu_freq" ]; then
            min_gpu_freq=257000000
        fi
        su -c "echo $min_gpu_freq > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq"
        sleep 1
    fi
    echo "GPU: conservative, 600MHz, configurada."

    echo "= PANTALLA Y ANIMACIONES ="
    sleep 1
    su -c "wm size 540x1140"
    sleep 1
    su -c "wm density 195"
    sleep 1
    su -c "settings put global window_animation_scale 0.3"
    sleep 1
    su -c "settings put global transition_animation_scale 0.3"
    sleep 1
    su -c "settings put global animator_duration_scale 0.3"
    sleep 1

    echo "Configurando ajustes del scheduler para balance..."
    su -c "sysctl -w kernel.sched_latency_ns=10000000"
    sleep 1
    su -c "sysctl -w kernel.sched_min_granularity_ns=2000000"
    sleep 1
    su -c "sysctl -w kernel.sched_wakeup_granularity_ns=2500000"
    echo "Latencia: 10ms, Granularidad mínima: 2ms, Wakeup: 2.5ms configurados."
    sleep 1

    echo "Configurando cpusets para balance..."
    su -c "echo 0-5 > /dev/cpuset/top-app/cpus"
    sleep 1
    su -c "echo 0-2 > /dev/cpuset/background/cpus"
    sleep 1
    su -c "echo 0-2 > /dev/cpuset/system-background/cpus"
    sleep 1
    su -c "echo 0-1 > /dev/cpuset/restricted/cpus"
    sleep 1
    su -c "echo 0-4 > /dev/cpuset/foreground/cpus"
    echo "Cpusets configurados para balance."
    sleep 1

    echo "Configurando estadísticas de I/O del almacenamiento..."
    su -c "echo 0 > /sys/block/mmcblk0/queue/iostats"
    echo "Estadísticas de I/O desactivadas."
    sleep 1
    echo "== 🟡 AHORRO NORMAL MEJORADO ACTIVADO 🟡 =="

# -- PERFIL 3: RENDIMIENTO MAXIMO
elif [ "$opcion" -eq 3 ]; then
    echo "Activando todos los nucleos..."
    sleep 1
    for cpu in 0 1 2 3 4 5 6 7; do
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: online"
    done

    echo "Configurando todos los nucleos..."
    sleep 1
    for cpu in 0 1 2 3 4 5 6 7; do
    su -c "echo performance > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1804000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
    su -c "echo 1804000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq"
        echo "CPU$cpu: performance, 1804MHz, online"
    done

    echo "Configurando GPU..."
    sleep 1
    su -c "echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
    su -c "echo 725000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"
    su -c "echo 725000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq"

    echo "Configurando pantalla y animaciones..."
    sleep 1
    su -c  wm size 540x1140
    su -c  wm density 210

    su -c "settings put global window_animation_scale 0"
    su -c "settings put global transition_animation_scale 0"
    su -c "settings put global animator_duration_scale 0"

    echo "Configurando ajustes del scheduler..."
    su -c "sysctl -w kernel.sched_latency_ns=9000000"
    su -c "sysctl -w kernel.sched_min_granularity_ns=1500000"
    su -c "sysctl -w kernel.sched_wakeup_granularity_ns=1900000"
    echo "Latencia: 9ms, Granularidad mínima: 1.5ms, Wakeup: 1.9ms configurados."
    sleep 1

    echo "Desactivando protección térmica..."
    su -c "stop thermal-engine"
    su -c "stop thermald" 2>/dev/null
    su -c "echo 0 > /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel" 2>/dev/null
    echo "Protección térmica desactivada."
    sleep 1

    echo "Configurando estadísticas de I/O del almacenamiento..."
    su -c "echo 0 > /sys/block/mmcblk0/queue/iostats"
    echo "Estadísticas de I/O desactivadas."
    sleep 1

    echo "Configurando cpusets para rendimiento máximo..."
    su -c "echo 0-7 > /dev/cpuset/top-app/cpus"
    su -c "echo 0-1 > /dev/cpuset/background/cpus"
    su -c "echo 0-3 > /dev/cpuset/system-background/cpus"
    su -c "echo 0-2 > /dev/cpuset/restricted/cpus"
    su -c "echo 0-5 > /dev/cpuset/foreground/cpus"
    echo "Cpusets configurados para rendimiento máximo."
    sleep 1


# -- PERFIL 4: VALORES DE FÁBRICA
elif [ "$opcion" -eq 4 ]; then
    echo "Restaurando valores de fábrica..."
    sleep 1
    # Restaurar parámetros de input boost si existen
    if su -c "test -f /data/local/tmp/ro_prev_input_boost_ms"; then
        prev_ms=$(su -c "cat /data/local/tmp/ro_prev_input_boost_ms" 2>/dev/null)
        su -c "echo $prev_ms > /sys/module/cpu_boost/parameters/input_boost_ms" 2>/dev/null || true
        su -c "rm -f /data/local/tmp/ro_prev_input_boost_ms" 2>/dev/null || true
    fi
    if su -c "test -f /data/local/tmp/ro_prev_input_boost_freq"; then
        prev_freq=$(su -c "cat /data/local/tmp/ro_prev_input_boost_freq" 2>/dev/null)
        su -c "echo \"$prev_freq\" > /sys/module/cpu_boost/parameters/input_boost_freq" 2>/dev/null || true
        su -c "rm -f /data/local/tmp/ro_prev_input_boost_freq" 2>/dev/null || true
    fi
    # Restaurar protecciones térmicas si fueron modificadas
    if su -c "test -f /data/local/tmp/ro_prev_thermal_pwrlevel"; then
        prev_tp=$(su -c "cat /data/local/tmp/ro_prev_thermal_pwrlevel" 2>/dev/null)
        su -c "echo $prev_tp > /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel" 2>/dev/null || true
        su -c "rm -f /data/local/tmp/ro_prev_thermal_pwrlevel" 2>/dev/null || true
    fi
    # Intentar reiniciar demonios termales si existen
    su -c "start thermal-engine" 2>/dev/null || true
    su -c "start thermald" 2>/dev/null || true

    # Restaurar estadísticas de I/O si fueron desactivadas
    su -c "echo 1 > /sys/block/mmcblk0/queue/iostats" 2>/dev/null || true

    # Restaurar ajustes de pantalla guardados por el perfil PANTALLA OLED
    for prev in /data/local/tmp/ro_prev_*; do
        [ -f "$prev" ] || continue
        name=$(basename "$prev")
        # Ignorar algunos prev ya manejados
        case "$name" in
            ro_prev_input_boost_ms|ro_prev_input_boost_freq|ro_prev_thermal_pwrlevel)
                continue
                ;;
        esac
        target=${name#ro_prev_}
        # intentar encontrar el fichero sysfs correspondiente
        target_path=$(su -c "for p in /sys/class/graphics/*/$target /sys/devices/**/$target; do [ -e \"\$p\" ] && echo \"\$p\" && break; done" 2>/dev/null)
        if [ -n "$target_path" ]; then
            val=$(su -c "cat $prev" 2>/dev/null)
            su -c "echo \"$val\" > $target_path" 2>/dev/null || true
            su -c "rm -f $prev" 2>/dev/null || true
            sleep 1
        else
            # Restaurar brillo si corresponde
            if [ "$name" = "ro_prev_screen_brightness" ]; then
                val=$(su -c "cat $prev" 2>/dev/null)
                su -c "settings put system screen_brightness $val" 2>/dev/null || true
                su -c "rm -f $prev" 2>/dev/null || true
                sleep 1
            fi
        fi
    done

    for cpu in 0 1 2 3 4 5 6 7; do
        su -c "echo schedutil > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
        su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: schedutil, online"
    done

    echo "Restaurando GPU..."
    su -c "echo msm-adreno-tz > /sys/class/kgsl/kgsl-3d0/devfreq/governor"

    echo "Restaurando resolución y densidad de pantalla..."
    su -c  wm size reset
    su -c  wm density reset

    echo "Restaurando animaciones..."
    su -c "settings put global window_animation_scale 1"
    su -c "settings put global transition_animation_scale 1"
    su -c "settings put global animator_duration_scale 1"

    echo "== 🔄 VALORES DE FÁBRICA RESTAURADOS 🔄 =="

# -- PERFIL 5: JUEGO (RENDIMIENTO EQUILIBRADO + EFICIENCIA)
elif [ "$opcion" -eq 5 ]; then
    echo "Activando modo JUEGO: rendimiento equilibrado y eficiencia"
    sleep 0.7

    # Activar todos los núcleos online (0-7) para máxima respuesta
    for cpu in 0 1 2 3 4 5 6 7; do
        su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: online"
        sleep 0.7
    done
    sleep 0.7

    # Cluster 1 (CPU0): elegir max = frecuencia más alta, min = ~60% del max (primer freq >= thresh)
    avail1=$(su -c "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies" 2>/dev/null)
    if [ -n "$avail1" ]; then
        sorted1=$(echo "$avail1" | tr ' ' '\n' | sort -n)
        max1=$(echo "$sorted1" | tail -n1)
        thresh1=$((max1 * 60 / 100))
        min1=$(echo "$sorted1" | awk -v t=$thresh1 '$1>=t {print $1; exit}')
        if [ -z "$min1" ]; then
            min1=$(echo "$sorted1" | head -n1)
        fi
    else
        # Valores seguros por defecto
        max1=1804000
        min1=1080000
    fi
    for cpu in 0 1 2 3; do
        su -c "echo schedutil > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
        sleep 0.7
        su -c "echo $max1 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
        sleep 0.7
        su -c "echo $min1 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq"
        sleep 0.7
        echo "CPU$cpu: schedutil, $(($max1 / 1000))MHz max, $(($min1 / 1000))MHz min"
    done

    # Cluster 2 (CPU4): priorizar estabilidad para performance, max = 2ª más alta, min = ~60% del max
    avail2=$(su -c "cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_available_frequencies" 2>/dev/null)
    if [ -n "$avail2" ]; then
        sorted2=$(echo "$avail2" | tr ' ' '\n' | sort -n)
        max2=$(echo "$sorted2" | tail -n1)
        second2=$(echo "$sorted2" | tail -n2 | head -n1)
        thresh2=$((max2 * 60 / 100))
        min2=$(echo "$sorted2" | awk -v t=$thresh2 '$1>=t {print $1; exit}')
        if [ -z "$min2" ]; then
            min2=$(echo "$sorted2" | head -n1)
        fi
        # usar second highest como max para ahorro moderado
        target_max2=${second2:-$max2}
    else
        target_max2=1500000
        min2=900000
    fi
    for cpu in 4 5 6; do
        su -c "echo performance > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
        sleep 0.7
        su -c "echo $target_max2 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
        sleep 0.7
        su -c "echo $min2 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq"
        sleep 0.7
        echo "CPU$cpu: performance, $(($target_max2 / 1000))MHz max, $(($min2 / 1000))MHz min"
    done

    # Ajuste específico de respuesta táctil: usar parámetros de cpu_boost si están disponibles
    touch_boost_ms=400  # duración del boost en ms (ajustable)
    if su -c "test -e /sys/module/cpu_boost/parameters/input_boost_ms"; then
        prev_ms=$(su -c "cat /sys/module/cpu_boost/parameters/input_boost_ms" 2>/dev/null)
        [ -n "$prev_ms" ] && su -c "echo $prev_ms > /data/local/tmp/ro_prev_input_boost_ms" 2>/dev/null || true
        su -c "echo $touch_boost_ms > /sys/module/cpu_boost/parameters/input_boost_ms" 2>/dev/null || true
        sleep 0.7
    fi
    if su -c "test -e /sys/module/cpu_boost/parameters/input_boost_freq"; then
        prev_freq=$(su -c "cat /sys/module/cpu_boost/parameters/input_boost_freq" 2>/dev/null)
        [ -n "$prev_freq" ] && su -c "echo \"$prev_freq\" > /data/local/tmp/ro_prev_input_boost_freq" 2>/dev/null || true
        # Formato habitual: "0:<freq0> 4:<freq4>"; usar max1 y target_max2 si existen
        new_freq="0:${max1:-$max1} 4:${target_max2:-$target_max2}"
        su -c "echo $new_freq > /sys/module/cpu_boost/parameters/input_boost_freq" 2>/dev/null || true
        sleep 0.7
    fi

    # GPU: máxima potencia para juegos (max al 100%, min al 70% para estabilidad)
    sleep 0.7
    if su -c "test -e /sys/class/kgsl/kgsl-3d0/devfreq/available_frequencies"; then
        g_avail=$(su -c "cat /sys/class/kgsl/kgsl-3d0/devfreq/available_frequencies")
        g_sorted=$(echo "$g_avail" | tr ' ' '\n' | sort -n)
        g_max=$(echo "$g_sorted" | tail -n1)
        g_thresh_min=$((g_max * 70 / 100))
        g_min=$(echo "$g_sorted" | awk -v t=$g_thresh_min '$1>=t {print $1; exit}')
        if [ -z "$g_min" ]; then
            g_min=$(echo "$g_sorted" | head -n1)
        fi
        su -c "echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
        sleep 0.7
        su -c "echo $g_max > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"
        sleep 0.7
        su -c "echo $g_min > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq"
        sleep 0.7
        echo "GPU: performance, $((g_max / 1000000))MHz max, $((g_min / 1000000))MHz min (máxima potencia)"
    else
        # Fallback agresivo
        su -c "echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
        sleep 0.7
        su -c "echo 725000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq" 2>/dev/null || true
        sleep 0.7
        su -c "echo 500000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq" 2>/dev/null || true
        sleep 0.7
        echo "GPU: performance, 725MHz max (fallback agresivo)"
    fi

    # Pantalla y animaciones para juego: mantener buena apariencia pero ahorrar
    sleep 0.7
    su -c "wm size 540x1135"
    sleep 0.7
    su -c "wm density 168"
    sleep 0.7
    su -c "settings put global window_animation_scale 0.5"
    sleep 0.7
    su -c "settings put global transition_animation_scale 0.5"
    sleep 0.7
    su -c "settings put global animator_duration_scale 0.5"
    sleep 0.7

    # Scheduler: latencia moderada para responsividad
    su -c "sysctl -w kernel.sched_latency_ns=9000000"
    sleep 0.7
    su -c "sysctl -w kernel.sched_min_granularity_ns=1600000"
    sleep 0.7
    su -c "sysctl -w kernel.sched_wakeup_granularity_ns=2000000"
    echo "Scheduler ajustado para juego."
    sleep 0.7

    # Cpusets: dar prioridad a top-app
    su -c "echo 0-7 > /dev/cpuset/top-app/cpus"
    sleep 0.7
    su -c "echo 0-1 > /dev/cpuset/background/cpus"
    sleep 0.7
    su -c "echo 0-2 > /dev/cpuset/system-background/cpus"
    sleep 0.7
    su -c "echo 0-1 > /dev/cpuset/restricted/cpus"
    sleep 0.7
    su -c "echo 0-4 > /dev/cpuset/foreground/cpus"
    echo "Cpusets configurados para modo juego."
    sleep 0.7

    # Desactivar estadísticas de I/O del almacenamiento para mejor rendimiento
    su -c "echo 0 > /sys/block/mmcblk0/queue/iostats"
    echo "Estadísticas de I/O desactivadas."
    sleep 0.7

    # Desactivar protecciones térmicas para mejorar rendimiento en juego (guardar estado previo)
    if su -c "test -e /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel"; then
        prev_tp=$(su -c "cat /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel" 2>/dev/null)
        if [ -n "$prev_tp" ]; then
            su -c "echo $prev_tp > /data/local/tmp/ro_prev_thermal_pwrlevel" 2>/dev/null || true
        fi
        sleep 0.7
        su -c "stop thermal-engine" 2>/dev/null || true
        sleep 0.7
        su -c "stop thermald" 2>/dev/null || true
        sleep 0.7
        su -c "echo 0 > /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel" 2>/dev/null || true
        echo "Protecciones térmicas desactivadas para modo juego."
    fi
    echo "== ⚪ PERFIL 5 (JUEGO) ACTIVADO ⚪ =="

# -- PERFIL 6: PANTALLA OLED (simular contraste y color tipo OLED)
elif [ "$opcion" -eq 6 ]; then
    echo "Activando modo PANTALLA OLED: ajustar color, contraste y saturación"
    sleep 1

    # Guardar brillo actual (system setting) y limitar si es muy alto
    prev_brightness=$(su -c "settings get system screen_brightness" 2>/dev/null)
    if [ -n "$prev_brightness" ]; then
        su -c "echo $prev_brightness > /data/local/tmp/ro_prev_screen_brightness" 2>/dev/null || true
        if [ "$prev_brightness" -gt 200 ]; then
            su -c "settings put system screen_brightness 200" 2>/dev/null || true
        fi
    fi
    sleep 1

    # Ajustes conservadores: aumentar saturación (x1.25) y contraste (x1.2) cuando existan
    for path in $(su -c 'for f in /sys/class/graphics/*/saturation /sys/devices/**/saturation /sys/class/graphics/*/contrast /sys/devices/**/contrast; do [ -e "$f" ] && echo "$f"; done' 2>/dev/null); do
        curr=$(su -c "cat $path" 2>/dev/null)
        if echo "$curr" | grep -qE '^[0-9]+$'; then
            su -c "echo $curr > /data/local/tmp/ro_prev_$(basename $path)" 2>/dev/null || true
            if echo "$path" | grep -qi saturation; then
                new=$((curr * 125 / 100))
            else
                new=$((curr * 120 / 100))
            fi
            su -c "echo $new > $path" 2>/dev/null || true
            echo "Ajustado $(basename $path): $curr -> $new"
            sleep 1
        fi
    done

    # Ajustar gamma por componente si existen gamma_r/gamma_g/gamma_b
    for comp in r g b; do
        for f in $(su -c 'for p in /sys/class/graphics/*/gamma_${comp} /sys/devices/**/gamma_${comp}; do [ -e "$p" ] && echo "$p"; done' 2>/dev/null); do
            curr=$(su -c "cat $f" 2>/dev/null)
            if [ -n "$curr" ]; then
                su -c "echo \"$curr\" > /data/local/tmp/ro_prev_$(basename $f)" 2>/dev/null || true
                new=$(echo "$curr" | awk '{for(i=1;i<=NF;i++){printf "%d", $i*110/100; if(i<NF) printf " ";}}')
                su -c "echo \"$new\" > $f" 2>/dev/null || true
                echo "Ajustado $(basename $f)"
                sleep 1
            fi
        done
    done

    # Intentar ajustar color balance / color matrix si existen (calentamiento ligero: subir rojo 5%, bajar azul 5%)
    for f in $(su -c 'for p in /sys/class/graphics/*/color* /sys/devices/**/color*; do [ -e "$p" ] && echo "$p"; done' 2>/dev/null); do
        curr=$(su -c "cat $f" 2>/dev/null)
        if [ -n "$curr" ]; then
            su -c "echo \"$curr\" > /data/local/tmp/ro_prev_$(basename $f)" 2>/dev/null || true
            new=$(echo "$curr" | awk '{if(NF==3){r=$1*105/100; g=$2; b=$3*95/100; printf "%d %d %d", r,g,b} else {printf "%s", $0}}')
            su -c "echo \"$new\" > $f" 2>/dev/null || true
            echo "Ajustado $(basename $f)"
            sleep 1
        fi
    done

    echo "Modo PANTALLA OLED aplicado (ajustes guardados en /data/local/tmp/ro_prev_* si corresponden)."

    # Nota: los ajustes serán restaurados al elegir Perfil 4 (Valores de fábrica)

    echo "== ⚫ PANTALLA OLED ACTIVADA ⚫ =="

else
    echo "Opción no válida. Saliendo."
    exit 1
fi
