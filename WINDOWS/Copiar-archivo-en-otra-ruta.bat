@echo off
set "ORIGEN=<ruta-origen>"
set "DESTINO=<ruta-destino>"

:: Crear carpeta destino si no existe
if not exist "%DESTINO%" mkdir "%DESTINO%"

:: Copiar archivo
copy /Y "%ORIGEN%" "%DESTINO%\"

echo completado
pause
