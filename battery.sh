#!/data/data/com.termux/files/usr/bin/bash

declare numValores=0
echo "Digite el numero de valores a promediar: "
read numValores

declare -a consumos
for ((i=1; i<=numValores; i++)); do
    consumoMAH=$(su -c "cat /sys/class/power_supply/battery/current_now")
    echo "consumo en mAh: $consumoMAH"
    consumos+=("$consumoMAH")
done

declare sumas=0
for ((j=0; j<${#consumos[@]}; j++)); do
    sumas=$(($sumas + ${consumos[j]}))
done

promedioConsumo=$(($sumas / ${#consumos[@]}))

echo "Consumo promedio en mAh: $promedioConsumo"