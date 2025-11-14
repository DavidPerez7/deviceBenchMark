#!/data/data/com.termux/files/usr/bin/bash

inicio=$(date +%s%N)
dd if=/dev/urandom of=testfile bs=1M count=5 status=none
tar czf testfile.tar.gz testfile
fin=$(date +%s%N)
duracion_ms=$(( (fin - inicio)/1000000 ))
duracion_s=$(echo "scale=2; $duracion_ms/1000" | bc)
echo "[Compresión] Tiempo: $duracion_s s"