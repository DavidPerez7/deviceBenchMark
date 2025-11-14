#!/data/data/com.termux/files/usr/bin/bash

# Configuración rápida de CPU
# CPU 0-3 (cluster 1): powersave, 1363 MHz, 4/4 núcleos
echo "-- CONFIGURACION DE OPTIMIZACIONES --"
sleep 1

declare opcion
echo "Elgina un perfil de optimizacion de CPU:"
echo "1. Ahorro EXTREMO (4 nucleos activos, a 1363 y 1094 MHz)"
echo "2. Ahorro NORMAL (6 nucleos activos a 1536 y 1401 MHz)"
echo "3. Rendimiento (8 nucleos activos a 1804 ambos)"
read opcion

# OPCION 1
if [ "$opcion" -eq 1 ]; then
    #apgado de nucleos
    for cpu in 2 3 6 7; do
    tsu -c "sh -c 'echo 0 > /sys/devices/system/cpu/cpu$cpu/online'"
        echo "CPU$cpu: offline"
    done
    # cluster 1 (freq y governor)
    for cpu in 0 1; do
    tsu -c "sh -c 'echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor'"
    tsu -c "sh -c 'echo 1363000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq'"
    tsu -c "sh -c 'echo 1 > /sys/devices/system/cpu/cpu$cpu/online'"
        echo "CPU$cpu: powersave, 1363MHz, online"
    done
    # cluster 2 (freq y governor)
    for cpu in 4 5; do
    tsu -c "sh -c 'echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor'"
    tsu -c "sh -c 'echo 1094000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq'"
    tsu -c "sh -c 'echo 1 > /sys/devices/system/cpu/cpu$cpu/online'"
        echo "CPU$cpu: powersave, 1094MHz, online"
    done

# OPCION 2
elif [ "$opcion" -eq 2 ]; then
    # apago de núcleos
    for cpu in 3 7; do
    tsu -c "sh -c 'echo 0 > /sys/devices/system/cpu/cpu$cpu/online'"
        echo "CPU$cpu: offline"
    done
    # cluster 1 (freq y governor)
    for cpu in 0 1 2; do
    tsu -c "sh -c 'echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor'"
    tsu -c "sh -c 'echo 1536000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq'"
    tsu -c "sh -c 'echo 1 > /sys/devices/system/cpu/cpu$cpu/online'"
        echo "CPU$cpu: powersave, 1536MHz, online"
    done
    # cluster 2 (freq y governor)
    for cpu in 4 5 6; do
    tsu -c "sh -c 'echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor'"
    tsu -c "sh -c 'echo 1401000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq'"
    tsu -c "sh -c 'echo 1 > /sys/devices/system/cpu/cpu$cpu/online'"
        echo "CPU$cpu: powersave, 1401MHz, online"
    done

# OPCION 3
elif [ "$opcion" -eq 3 ]; then
    # Encender todos los núcleos
    for cpu in 0 1 2 3 4 5 6 7; do
    tsu -c "sh -c 'echo 1 > /sys/devices/system/cpu/cpu$cpu/online'"
        echo "CPU$cpu: online"
    done
    # cluster 1-2 (freq y governor)
    for cpu in 0 1 2 3 4 5 6 7; do
    tsu -c "sh -c 'echo performance > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor'"
    tsu -c "sh -c 'echo 1804000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq'"
        echo "CPU$cpu: performance, 1804MHz, online"
    done
else
    echo "Opción no válida. Saliendo."
    exit 1
fi

sleep 1
echo "-- CONFIGURACION COMPLETADA --"
