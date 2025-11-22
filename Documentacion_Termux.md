# BatteryOpt: Comandos funcionales, problemas y limitaciones

## 1. Permisos y ejecución de scripts
- Usa siempre `bash script.sh` o `./script.sh` (con shebang correcto) para scripts con sintaxis de bash.
- Da permisos de ejecución con:
  ```bash
  chmod +x script.sh
  ```
- Para ejecutar scripts como root en Termux, usa la ruta absoluta de bash:
  ```bash
  su -c "/data/data/com.termux/files/usr/bin/bash /data/data/com.termux/files/home/BatteryOpt/mainScripts/setOpt.sh"
  ```

### Ejemplo de ejecutable para scripts root:
```bash
#!/data/data/com.termux/files/usr/bin/bash
su -c "/data/data/com.termux/files/usr/bin/bash /data/data/com.termux/files/home/BatteryOpt/mainScripts/setOpt.sh"
```
Así puedes ejecutar el script con solo `./ejecutable.sh`.

---

## 2. Root en Termux
- En este dispositivo, el root funcional es con `su -c` y redirección directa.
- Ejemplo de uso correcto para redirección:
  ```bash
  su -c "echo valor > /ruta/al/archivo"
  ```
- El uso de `tsu` y `tee` puede no funcionar correctamente en todos los dispositivos.

### Notas sobre root:
- El binario bash en Termux está en `/data/data/com.termux/files/usr/bin/bash`.
- El root por `su -c` ejecuta cada comando en una subshell root, pero el script completo puede requerir ejecutarse como root para aplicar todos los cambios correctamente.

---

## 3. SELinux y seguridad
- Verifica el estado con:
  ```bash
  getenforce
  ```
- Si está en `Enforcing`, ponlo en `Permissive` (si tu ROM lo permite):
  ```bash
  su -c setenforce 0
  ```

### Notas:
- SELinux en modo enforcing puede bloquear cambios en governor, frecuencias y otros parámetros, incluso con root.

---

## 4. Verificación de rutas y permisos
- Antes de escribir, verifica que el archivo existe:
  ```bash
  ls -l /sys/devices/system/cpu/cpu0/cpufreq/
  ```
- Si no existe, revisa la documentación de tu kernel o usa `find` para buscar la ruta correcta.

### Ejemplo para buscar rutas:
```bash
find /sys -name "scaling_max_freq"
```
Así puedes encontrar la ruta real si tu kernel la mueve.

---

## 5. Comandos y configuraciones que funcionan

### Ejemplo de comando funcional para CPU:
```bash
su -c "echo 0 > /sys/devices/system/cpu/cpu0/online"
su -c "echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
su -c "echo 1363000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
```

> **Nota:** Aunque el comando es funcional para cambiar el governor, en la mayoría de dispositivos Android el cambio se aplica a todo el clúster de CPUs al que pertenece el núcleo seleccionado (por ejemplo, CPUs 0-3 o 4-7), no solo al hilo específico. Así, cambiar el governor de cpu0 generalmente afecta a todos los núcleos de ese clúster.

### Ejemplo para GPU:
```bash
su -c "echo powersave > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
su -c "echo 400000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq"
```

**Nota:** El governor y la frecuencia de la GPU pueden no aplicarse desde scripts con `su -c` en comandos individuales, pero sí funciona si ejecutas el script completo como root.

### Ejemplo para pantalla (resolución y densidad):
```bash
su -c "wm size 640x1280"
su -c "wm density 235"
```

Para restablecer valores originales:
```bash
su -c "wm size reset"
su -c "wm density reset"
```

### Ejemplo para animaciones:
```bash
su -c "settings put global window_animation_scale 0.2"
su -c "settings put global transition_animation_scale 0.2"
su -c "settings put global animator_duration_scale 0.2"
```

Valores recomendados: 0 (desactivado), 0.1-0.3 (rápido pero visible), 0.5 (normal), 0.8-1.0 (más lento).

---

## 6. Comandos que pueden fallar
- `declare` solo funciona en bash, no en sh.
- Redirecciones con `>` dentro de `tsu -c` pueden fallar.
- Algunos kernels no permiten modificar governors/frecuencias aunque seas root.
- El governor y la frecuencia de la GPU pueden no aplicarse desde scripts, pero sí manualmente en la terminal. Ejecutar el script completo como root puede ayudar.
- La frecuencia de refresco de pantalla suele estar fijada por el fabricante y no puede cambiarse con `settings put system peak_refresh_rate` ni otros comandos.

---

## 7. Limitaciones de frecuencia de refresco de pantalla

En muchos dispositivos Android, la frecuencia de refresco de pantalla está fijada por el fabricante y no puede cambiarse por comandos (`settings put system peak_refresh_rate`, etc.). Puedes consultar la frecuencia actual con:
```bash
cat /sys/class/graphics/fb0/modes
```

Si solo aparece un valor (por ejemplo, `U:720x1520p-57`), esa es la única frecuencia soportada por hardware/firmware.

**Conclusión:**
La optimización de pantalla se limita a resolución y densidad (DPI). La tasa de refresco solo puede cambiarse si el fabricante/ROM lo permite.

---

## 8. Limitaciones del cambio de frecuencia máxima en cluster 0

En algunos dispositivos Android, aunque tengas permisos root y el comando `su -c "echo valor > /sys/devices/system/cpu/cpuX/cpufreq/scaling_max_freq"` no muestre error, la frecuencia máxima del cluster 0 (por ejemplo, CPUs 0-3) puede no cambiar realmente. Esto se debe a:

- Restricciones del kernel o de la ROM, que bloquean cambios en ciertas frecuencias por seguridad.
- Daemons del sistema (como thermal, powerd, etc.) que restablecen la frecuencia automáticamente.
- SELinux en modo enforcing, que puede bloquear cambios incluso con root.

Herramientas como EX Kernel Manager pueden cambiar la frecuencia máxima porque:
- Usan un daemon propio con permisos root persistentes otorgados por Magisk desde el arranque.
- Pueden aplicar parches adicionales al kernel o a SELinux.

**Conclusión:**
No es un fallo del script, sino una limitación del kernel/ROM. El script funciona para lo que permite el sistema con root estándar. Si necesitas cambiar la frecuencia máxima del cluster 0, deberás usar herramientas avanzadas como EX Kernel Manager con Magisk y su daemon, lo cual está fuera del alcance de este proyecto.

---

## 9. Recomendaciones generales
- Siempre prueba comandos manualmente antes de automatizarlos en scripts.
- Documenta los comandos que funcionan y los que no, según tu dispositivo y ROM.
- Si un comando no da error pero no aplica el cambio, revisa permisos, SELinux y compatibilidad del kernel.
- Mantén este documento actualizado con cada hallazgo nuevo.

---

**Actualiza este documento cada vez que encuentres un comando útil, una limitación o un problema nuevo.**
