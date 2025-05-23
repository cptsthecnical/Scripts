@echo off
color 0C
echo Script para ejecutar un archivo como admin desde Anydesk
pause
setlocal
:: script de Windows para entrar como Administrador en sesiones (pensado para Anydesk)::
:: también se puede utilizar : https://support.anydesk.com/es/knowledge/administrative-privileges-and-elevation-uac

:: Preguntar dominio
echo Introduce el nombre del dominio 
set /p dominio= (ej: apple.com): 

:: Preguntar ruta del archivo a ejecutar
echo Introduce la ruta completa del archivo que quieres abrir "con comillas si tiene espacios" 
set /p ruta= (ej: "notepad.exe C:\Windows\System32\drivers\etc\hosts"):

:: Preguntar usuario
echo Introduce el nombre de usuario de Active Directory 
set /p usuario= (ej: craig.federighi): 

:: Ejecutar con runas usando los datos introducidos
C:\Windows\System32\runas /user:%dominio%\%usuario% %ruta%

endlocal
