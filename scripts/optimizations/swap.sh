#!/data/data/com.termux/files/usr/bin/bash

# Desactiva el swap actual
echo "[1/5] Desactivando el swap actual..."
su -c 'swapoff /dev/block/zram0'

# Resetea el dispositivo zram
echo "[2/5] Reseteando el dispositivo zram..."
su -c 'echo 1 > /sys/block/zram0/reset'

# Configura el tamaño del dispositivo zram a 1.5 GB
echo "[3/5] Configurando el tamaño del dispositivo zram a 1.5 GB..."
su -c 'echo 1610612736 > /sys/block/zram0/disksize'

# Prepara el dispositivo zram como swap
echo "[4/5] Preparando el dispositivo zram como swap..."
su -c 'mkswap /dev/block/zram0'

# Activa el swap
echo "[5/5] Activando el swap..."
su -c 'swapon /dev/block/zram0'

echo "Proceso completado con éxito."