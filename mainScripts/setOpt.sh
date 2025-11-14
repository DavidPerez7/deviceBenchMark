#!/data/data/com.termux/files/usr/bin/bash

# Configuración rápida de CPU
# CPU 0-3 (cluster 1): powersave, 1363 MHz, 4/4 núcleos

for cpu in 0 1 2 3; do
    su -c "echo powersave > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1363000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
    echo "CPU$cpu: powersave, 1363MHz, online"
done

# CPU 4-6 (cluster 2): schedutil, 1401 MHz, 3/4 núcleos
for cpu in 4 5 6; do
    su -c "echo schedutil > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor"
    su -c "echo 1401000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq"
    su -c "echo 1 > /sys/devices/system/cpu/cpu$cpu/online"
    echo "CPU$cpu: schedutil, 1401MHz, online"
done

# Desactivar CPU 7 (solo 3/4 en cluster 2)
su -c "echo 0 > /sys/devices/system/cpu/cpu7/online"
echo "CPU7: offline"

echo "Configuración aplicada."
