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

---

Actualiza este documento cada vez que encuentres un comando útil o un problema nuevo.
