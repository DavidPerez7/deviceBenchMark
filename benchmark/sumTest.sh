#!/data/data/com.termux/files/usr/bin/bash

inicio=$(date +%s%N)
sum=0
for ((i=1; i<=500000; i++)); do
    sum=$((sum + i))
done
fin=$(date +%s%N)

elapsed_sum_ms=$(( (fin - inicio)/1000000 ))
elapsed_sum_s=$(echo "scale=2; $elapsed_sum_ms/1000" | bc)
echo "[Suma] Tiempo: $elapsed_sum_s s | Suma: $sum"