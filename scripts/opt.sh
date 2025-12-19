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
echo ""
echo "Ingresa el número de opción (1-4):"
read opcion


sleep 1

# -- PERFIL 1: EXTREMO
if [ "$opcion" -eq 1 ]; then
    echo "Apagando nucleos..."
    sleep 1
    for cpu in 1 2 3 7; do
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
    sleep 2
    su -c "echo powersave > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
    sleep 2
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
    for cpu in 3 7; do
    su -c "echo 0 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: offline"
    done
    echo "= CLUSTER 1 ="
    for cpu in 0 1 2; do
    su -c "echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1536000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: powersave, 1536MHz, online"
    done
    echo "= CLUSTER 2 ="
    for cpu in 4 5 6; do
    su -c "echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1401000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: powersave, 1401MHz, online"
    done
    
    echo "= GPU ="
    su -c "echo powersave > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
    su -c "echo 560000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"

    echo "= PANTALLA Y ANIMACIONES ="
    su -c  wm size reset  # para el redmi 7 es 720x1520
    su -c  wm density 265

    su -c "settings put global window_animation_scale 0.2"
    su -c "settings put global transition_animation_scale 0.2"
    su -c "settings put global animator_duration_scale 0.2"

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

else
    echo "Opción no válida. Saliendo."
    exit 1
fi
