#!/data/data/com.termux/files/usr/bin/bash

# Configuración rápida de CPU
# CPU 0-3 (cluster 1): powersave, 1363 MHz, 4/4 núcleos
echo "-- CONFIGURACION DE OPTIMIZACIONES --"
sleep 1

declare opcion
echo "Elgina un perfil de optimizacion de CPU:"
echo "1. Ahorro EXTREMO (4 nucleos activos, a 1363 y 1094 MHz)"
echo "2. Ahorro NORMAL (6 nucleos activos a 1536 y 1401 MHz)"
echo "3. Rendimiento (8 nucleos activos a 1804MHz)"
read opcion

# -- OPCION 1
if [ "$opcion" -eq 1 ]; then
    echo "= APAGANDO NUCLEOS ="
    for cpu in 1 2 3 7; do
    su -c "echo 0 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: offline"
    done
    echo "= CLUSTER 1 ="
    for cpu in 0; do
    su -c "echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1363000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: powersave, 1363MHz, online"
    done
    echo "= CLUSTER 2 ="
    for cpu in 4 5 6; do
    su -c "echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1094000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: powersave, 1094MHz, online"
    done

    echo "= GPU ="
    su -c "echo powersave > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
    su -c "echo 400000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"

    echo "= PANTALLA Y ANIMACIONES ="
    su -c  wm size 640x1280
    su -c  wm density 235

    su -c "settings put global window_animation_scale 0.1"
    su -c "settings put global transition_animation_scale 0.1"
    su -c "settings put global animator_duration_scale 0.1"
    

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
    su -c  wm size 640x1280
    su -c  wm density 235

    su -c "settings put global window_animation_scale 0.2"
    su -c "settings put global transition_animation_scale 0.2"
    su -c "settings put global animator_duration_scale 0.2"

# -- OPCION 3
elif [ "$opcion" -eq 3 ]; then
    echo "= ENCENDIENDO NUCLEOS ="
    for cpu in 0 1 2 3 4 5 6 7; do
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
        echo "CPU$cpu: online"
    done
    echo "= CLUSTERS (ALL) ="
    for cpu in 0 1 2 3 4 5 6 7; do
    su -c "echo performance > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1804000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
        echo "CPU$cpu: performance, 1804MHz, online"
    done

    echo "= GPU ="
    su -c "echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
    su -c "echo 725000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"

    echo "= PANTALLA Y ANIMACIONES ="
    su -c  wm size reset
    su -c  wm density 265

    su -c "settings put global window_animation_scale 0.8"
    su -c "settings put global transition_animation_scale 0.8"
    su -c "settings put global animator_duration_scale 0.8"

else
    echo "Opción no válida. Saliendo."
    exit 1
fi

sleep 1
echo "-- CONFIGURACION COMPLETADA --"
