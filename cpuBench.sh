#!/data/data/com.termux/files/usr/bin/bash

start=$(date +%s%N)
sum=0
for ((i=1; i<=2000000; i++)); do
    sum=$((sum + i))
done
end=$(date +%s%N)
elapsed_ms=$(( (end - start)/1000000 )) # milisegundos
elapsed_s=$(echo "scale=2; $elapsed_ms/1000" | bc)
echo "Tiempo total: $elapsed_s s"
echo "Suma: $sum"