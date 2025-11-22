#!/data/data/com.termux/files/usr/bin/bash

declare numConsultas=50
declare capacidadMAH=$(su -c "cat /sys/class/power_supply/battery/charge_full")
echo "-- CONSULTAS DE CONSUMO DE BATERÍA --"
sleep 1
echo "Capacidad de la batería en mAh: $capacidadMAH"
echo "Número de consultas a realizar: $numConsultas"

declare -a consumos
for ((i=1; i<=numConsultas; i++)); do
    consumoMAH=$(su -c "cat /sys/class/power_supply/battery/current_now")
    echo "consumo en mAh: $consumoMAH"
    consumos+=("$consumoMAH")
    sleep 1.35
done

declare sumas=0
for ((j=0; j<${#consumos[@]}; j++)); do
    sumas=$(($sumas + ${consumos[j]}))
done

promedioConsumo=$(($sumas / ${#consumos[@]}))
promedioPorcentaje=$((($promedioConsumo * 100) / $capacidadMAH))

sleep 1
echo "Consumo promedio en mAh: $promedioConsumo"
echo "Consumo promedio en porcentaje /h: $promedioPorcentaje%"
echo "-- FIN DE CONSULTAS --"