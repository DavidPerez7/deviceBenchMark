# 📱 RedmiOpt: Registro de Desarrollo en Redmi 7 (Lineage OS)

¡Bienvenido a mi registro personal de desarrollo de **RedmiOpt**! Aquí documento lo que he aprendido y las experiencias que he tenido desarrollando scripts de optimización para mi Redmi 7 rooteado con Lineage OS. No es una guía general, sino un diario de hallazgos, problemas y soluciones específicas para este dispositivo. 🚀

## 📋 Índice de Experiencias
- [1. 🔐 Inicio del Proyecto y Permisos](#1-inicio-del-proyecto-y-permisos)
- [2. 🔑 Root y Configuración Inicial](#2-root-y-configuración-inicial)
- [3. ⚙️ Comandos que Funcionaron en mi Dispositivo](#3-comandos-que-funcionaron-en-mi-dispositivo)
- [4. ❌ Problemas y Fallos Encontrados](#4-problemas-y-fallos-encontrados)
- [5. 📺 Limitaciones de Pantalla en Redmi 7](#5-limitaciones-de-pantalla-en-redmi-7)
- [6. ✅ Lecciones Aprendidas](#6-lecciones-aprendidas)
- [7. 🧪 Experiencia con ZRAM y Swap](#7-experiencia-con-zram-y-swap)

---

## 1. 🔐 Inicio del Proyecto y Permisos
Empecé RedmiOpt para optimizar RAM y swap en mi Redmi 7, pero rápidamente me di cuenta de que necesitaba manejar permisos correctamente. 🔒

- Siempre uso `bash script.sh` para ejecutar scripts, ya que bash soporta funciones avanzadas de programación como bucles, arrays y más, que sh no tiene. No necesito dar permisos de ejecución con `chmod +x` si uso bash directamente.
- Para root en Termux, uso la ruta absoluta de bash: `su -c "/data/data/com.termux/files/usr/bin/bash script.sh"`, porque el PATH de root no incluye Termux.
- Creé un ejecutable wrapper para simplificar: `#!/data/data/com.termux/files/usr/bin/bash` seguido de `su -c` para ejecutar scripts completos.

**Lección:** Bash es esencial para scripts complejos; sh limita las funcionalidades.

---

## 2. 🔑 Root y Configuración Inicial
Rootear el Redmi 7 con Lineage OS fue el primer paso, pero configurar comandos root fue un reto. 🛠️

- `su -c` funciona bien para redirecciones simples como `su -c "echo valor > archivo"`.
- `tsu` y `tee` no funcionaron en mi setup, así que me quedé con `su -c`.
- El binario bash de Termux está en `/data/data/com.termux/files/usr/bin/bash`, y root ejecuta en subshells, lo que requiere scripts completos como root.

**Experiencia:** Al principio, comandos individuales fallaban, pero scripts enteros aplicaban cambios. Aprendí a ejecutar todo el script como root.

---

## 3. ⚙️ Comandos que Funcionaron en mi Dispositivo
Después de pruebas, estos comandos aplicaron cambios en mi Redmi 7. ✅

### 🖥️ CPU:
```bash
su -c "echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
su -c "echo 1363000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
```
Afecta al cluster completo (CPUs 0-3).

### 🎮 GPU:
```bash
su -c "echo powersave > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
su -c "echo 400000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"
```
Funciona manualmente, pero no siempre desde scripts individuales.

### 📱 Pantalla:
```bash
su -c "wm size 640x1280"
su -c "wm density 235"
```
Reset con `wm size reset` y `wm density reset`.

### 🎨 Animaciones:
```bash
su -c "settings put global window_animation_scale 0.2"
```
Valores bajos aceleran, pero 0 desactiva.

**Nota:** En mi dispositivo, estos aplican bien con SELinux en Permissive.

---

## 4. ❌ Problemas y Fallos Encontrados
Muchos comandos fallaron inicialmente. 🚫

- `declare` no funciona en sh, solo bash.
- Redirecciones con `tsu -c` fallaban.
- Los valores de frecuencia de GPU no se colocaban al inicio por falta de permisos (no usaba `su -c`). Además, en mi dispositivo no se puede cambiar la frecuencia directamente a todos los núcleos con un solo comando al cluster; toca hacerlo núcleo por núcleo. El núcleo 0 es como 'rebelde' porque el kernel no hace casi nada y no setea los valores que se indican.
- Frecuencia de refresco fija por hardware; `settings put system peak_refresh_rate` no cambia nada.
- Algunos cambios de frecuencia máxima en cluster 0 no se aplicaban realmente, a pesar de no dar error.

**Frustración:** Pasé horas debuggeando por qué comandos no daban error pero no cambiaban nada. Resultado: daemons del sistema o kernel restricciones.

---

## 5. 📺 Limitaciones de Pantalla en Redmi 7
La pantalla de mi Redmi 7 tiene frecuencia fija. 🔄

- `cat /sys/class/graphics/fb0/modes` muestra solo `U:720x1520p-57`, una frecuencia.
- No pude cambiarla con comandos; está fijada por el fabricante.
- Optimización limitada a resolución y DPI.

**Lección:** No perder tiempo en lo que el hardware no permite.

---

## 6. ✅ Lecciones Aprendidas
Reflexiones después de desarrollar RedmiOpt. 💡

- Siempre prueba manualmente antes de script.
- Documenta lo que funciona y falla en tu dispositivo específico.
- Si no da error pero no cambia, revisa SELinux, permisos y kernel.
- Mantén actualizado este registro con nuevos hallazgos.
- Para Redmi 7 con Lineage OS, enfócate en lo que el kernel permite.

**Consejo:** Este proyecto me enseñó paciencia; no todo se optimiza igual en todos los dispositivos.

---

## 7. 🧪 Experiencia con ZRAM y Swap
Esta fue una de las experiencias más frustrantes y educativas en el desarrollo de RedmiOpt. Empezó cuando decidí crear perfiles de optimización para RAM y swap, enfocándome en benchmarks como Antutu para comparar rendimiento con y sin swap activo. 🔄

### Creación Inicial de ZRAM
Al principio, para probar perfiles de procesamiento intensivo (sin compresión) y compresión (con zram), creé manualmente un dispositivo zram desde Termux. Usé comandos como:
```bash
su -c "echo 1 > /sys/block/zram0/reset"
su -c "echo 512M > /sys/block/zram0/disksize"
su -c "mkswap /dev/block/zram0"
su -c "swapon /dev/block/zram0"
```
Esto me permitió tener swap comprimido para simular escenarios de baja RAM.

### Problema con ExKernelManager
Después de instalar ExKernelManager para otras pruebas (como overclocking), noté que recreaba zram automáticamente al arranque. Cuando lo desinstalé para benchmarks limpios, zram seguía apareciendo después de reiniciar. Intenté eliminarlo permanentemente con:
```bash
su -c "swapoff /dev/block/zram0"
su -c "echo 1 > /sys/block/zram0/reset"
su -c "rmmod zram"
```
Pero `rmmod` fallaba con "module zram is builtin", indicando que no era un módulo cargable.

### Investigación en el Kernel
Profundicé en el problema. Usé `dmesg` para ver logs del kernel:
```bash
dmesg | grep -i zram
```
Confirmé que zram estaba integrado en el kernel de mi Redmi 7 (4.9.337), con `CONFIG_ZRAM=y` compilado. Esto significa que zram se inicializa automáticamente al arranque y no se puede "eliminar" sin recompilar el kernel o modificar el initramfs.

### Solución: Neutralización en Lugar de Eliminación
Para benchmarks limpios, aprendí a "neutralizar" zram en lugar de eliminarlo. Poniendo `disksize=0`, el dispositivo queda inactivo, equivalente a no tener swap. Comandos:
```bash
su -c "echo 1 > /sys/block/zram0/reset"
su -c "echo 0 > /sys/block/zram0/disksize"
su -c "swapoff /dev/block/zram0"
```
Verifiqué el estado con:
- `cat /sys/block/zram0/disksize` (debe ser 0)
- `cat /proc/swaps` (no debe listar zram0)
- `free -h` (Swap debe ser 0B)

### Agregando Diagnóstico al Script
Para asegurar que zram estuviera neutralizado antes de benchmarks, agregué un pre-reboot diagnóstico en RamOpt.sh:
```bash
echo "Verificando estado de ZRAM/Swap..."
uname -a
free -h
cat /proc/swaps
dmesg | egrep -i "zram|swap|swapon|mkswap" | tail -n 10
```
Esto me ayudó a confirmar que zram no afectaba los resultados.

### Recomendación de Neutralizador en Arranque
Para persistencia, recomendé instalar un script neutralizador que se ejecute muy temprano en el arranque, antes de que cualquier app o daemon active zram. Esto se puede hacer con Termux:Boot o editando init.d/service.d.

**Ejemplo de script neutralizador (early-boot):**
```sh
#!/system/bin/sh
Z=/sys/block/zram0
if [ -e "$Z" ]; then
  echo 1 > $Z/reset 2>/dev/null || true
  echo 0 > $Z/disksize 2>/dev/null || true
  [ -e /dev/block/zram0 ] && swapoff /dev/block/zram0 2>/dev/null || true
fi
```

**Lección:** Zram es útil para optimización, pero para benchmarks comparables, neutralizarlo es clave. No siempre se puede eliminar todo; a veces, la solución es adaptar. Esto me enseñó sobre la integración profunda del kernel en Android y la importancia de verificación post-cambio.

---

**Actualiza este registro con cada nueva experiencia en RedmiOpt.** 🎉
