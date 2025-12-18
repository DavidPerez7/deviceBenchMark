#!/data/data/com.termux/files/usr/bin/bash

# Configuración rápida de CPU
# CPU 0-3 (cluster 1): powersave, 1363 MHz, 4/4 núcleos
echo "====================================="
echo "== CONFIGURACION DE OPTIMIZACIONES =="
echo "====================================="
sleep 1

declare opcion
echo "Elgina un perfil de optimizacion de CPU:"
echo "1. 🔴 AHORRO EXTREMO (4 nucleos - GPU a 400MHz - resolucion 560x1000, 170dpi)"
echo "2. 🟡 AHORRO NORMAL (6 nucleos activos a 1536 y 1401 MHz)"
echo "3. 🟢 RENDIMIENTO MAXIMO (8 nucleos activos a 1804MHz)"
echo "4. 🔄 VALORES DE FÁBRICA (schedutil, resolución y animaciones predeterminadas)"
read opcion

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
    su -c "echo conservative > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1363000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: conservative, 1363MHz, online"
    done
    echo "Configurando cluster 2..."
    sleep 1
    for cpu in 4 5 6; do
    su -c "echo conservative > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1094000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: powersave, 1094MHz, online"
    done

    echo "Configurando GPU..."
    sleep 1
    su -c "echo powersave > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
    su -c "echo 400000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"
    echo "GPU: powersave, 400MHz, online"

    echo "Configurando pantalla... "
    sleep 1
    su -c  wm size 560x1000
    su -c  wm density 170
    echo "Screen: 560x1230, 160dpi"

    echo "Desactivando animaciones..."
    sleep 1
    su -c "settings put global window_animation_scale 0"
    su -c "settings put global transition_animation_scale 0"
    su -c "settings put global animator_duration_scale 0"
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
    su -c  wm size 640x1280
    su -c  wm density 235

    su -c "settings put global window_animation_scale 0"
    su -c "settings put global transition_animation_scale 0"
    su -c "settings put global animator_duration_scale 0"

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
