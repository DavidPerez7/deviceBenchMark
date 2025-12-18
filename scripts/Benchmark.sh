#!/data/data/com.termux/files/usr/bin/bash

inicio=$(date +%s%N)

# Ejecutar los tests organizados
bash benchmark/sumTest.sh
bash benchmark/compressionTest.sh
bash benchmark/textTest.sh

fin=$(date +%s%N)
duracion_total_ms=$(( (fin - inicio)/1000000 ))
duracion_total_s=$(echo "scale=2; $duracion_total_ms/1000" | bc)
echo "[TOTAL] Benchmark mixto: $duracion_total_s s"

# Limpieza
rm -f testfile testfile.tar.gz bigtext.txt