# BatteryOpt: Comandos funcionales y errores

## 1. Permisos y ejecución de scripts
- Usa siempre `bash script.sh` o `./script.sh` (con shebang correcto) para scripts con sintaxis de bash.
- Da permisos de ejecución con:
  ```bash
  chmod +x script.sh
  ```

## 2. Root en Termux
- En este dispositivo, el root funcional es con `su -c` y redirección directa.
- Ejemplo de uso correcto para redirección:
  ```bash
  su -c "echo valor > /ruta/al/archivo"
  ```
- El uso de `tsu` y `tee` puede no funcionar correctamente en todos los dispositivos.

## 3. SELinux
- Verifica el estado con:
  ```bash
  getenforce
  ```
- Si está en `Enforcing`, ponlo en `Permissive` (si tu ROM lo permite):
  ```bash
  su -c setenforce 0
  ```

## 4. Verificación de rutas y permisos
- Antes de escribir, verifica que el archivo existe:
  ```bash
  ls -l /sys/devices/system/cpu/cpu0/cpufreq/
  ```
- Si no existe, revisa la documentación de tu kernel o usa `find` para buscar la ruta correcta.

## 5. Comandos que pueden fallar
- `declare` solo funciona en bash, no en sh.
- Redirecciones con `>` dentro de `tsu -c` pueden fallar.
- Algunos kernels no permiten modificar governors/frecuencias aunque seas root.

## 6. Ejemplo de comando funcional
```bash
su -c "echo 0 > /sys/devices/system/cpu/cpu0/online"
su -c "echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
```

> **Nota:** Aunque el comando `su -c "echo powersave > /sys/devices/system/cpu/cpuX/cpufreq/scaling_governor"` es funcional para cambiar el governor, en la mayoría de dispositivos Android el cambio se aplica a todo el clúster de CPUs al que pertenece el núcleo seleccionado (por ejemplo, CPUs 0-3 o 4-7), no solo al hilo específico. Así, cambiar el governor de cpu0 generalmente afecta a todos los núcleos de ese clúster.

## 7. Recomendaciones
- Siempre prueba comandos manualmente antes de automatizarlos en scripts.
- Documenta los comandos que funcionan y los que no, según tu dispositivo y ROM.
- Si un comando no da error pero no aplica el cambio, revisa permisos, SELinux y compatibilidad del kernel.

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

Actualiza este documento cada vez que encuentres un comando útil o un problema nuevo.
