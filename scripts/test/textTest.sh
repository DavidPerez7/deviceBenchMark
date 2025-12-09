#!/data/data/com.termux/files/usr/bin/bash

inicio=$(date +%s%N)
head -c 500000 /dev/urandom | base64 > bigtext.txt
grep "A" bigtext.txt > /dev/null
fin=$(date +%s%N)
duracion_ms=$(( (fin - inicio)/1000000 ))
duracion_s=$(echo "scale=2; $duracion_ms/1000" | bc)
echo "[Texto] Tiempo: $duracion_s s"