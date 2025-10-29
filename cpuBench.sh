#!/data/data/com.termux/files/usr/bin/bash

echo "Tiempo total: $elapsed_s s"
echo "Suma: $sum"

start_total=$(date +%s%N)

# 1. Suma grande
start_sum=$(date +%s%N)
sum=0
for ((i=1; i<=500000; i++)); do
    sum=$((sum + i))
done
end_sum=$(date +%s%N)
elapsed_sum_ms=$(( (end_sum - start_sum)/1000000 ))
elapsed_sum_s=$(echo "scale=2; $elapsed_sum_ms/1000" | bc)
echo "[Suma] Tiempo: $elapsed_sum_s s | Suma: $sum"

# 2. Compresión de archivo
start_comp=$(date +%s%N)
dd if=/dev/urandom of=testfile bs=1M count=5 status=none
tar czf testfile.tar.gz testfile
end_comp=$(date +%s%N)
elapsed_comp_ms=$(( (end_comp - start_comp)/1000000 ))
elapsed_comp_s=$(echo "scale=2; $elapsed_comp_ms/1000" | bc)
echo "[Compresión] Tiempo: $elapsed_comp_s s"

# 3. Procesamiento de texto
start_text=$(date +%s%N)
head -c 500000 /dev/urandom | base64 > bigtext.txt
grep "A" bigtext.txt > /dev/null
end_text=$(date +%s%N)
elapsed_text_ms=$(( (end_text - start_text)/1000000 ))
elapsed_text_s=$(echo "scale=2; $elapsed_text_ms/1000" | bc)
echo "[Texto] Tiempo: $elapsed_text_s s"

# Tiempo total
end_total=$(date +%s%N)
elapsed_total_ms=$(( (end_total - start_total)/1000000 ))
elapsed_total_s=$(echo "scale=2; $elapsed_total_ms/1000" | bc)
echo "[TOTAL] Benchmark mixto: $elapsed_total_s s"

# Limpieza
rm -f testfile testfile.tar.gz bigtext.txt