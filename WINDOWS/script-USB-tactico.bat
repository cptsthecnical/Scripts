@echo off
setlocal enabledelayedexpansion
## es mejor ejecutar este script .bat que en .ps1 porque en los active directory se suele bloquear los .ps1
## script para Windows en powershell para migrar con doble click mis apuntes públicos a un USB

# Configuración
set "DestinationFolder=E:\00-MANUALES"        # Cambiar por tu unidad USB
set "GitHubToken=TOKEN"                       # Solo necesario para repos privados

:: Crear carpeta de destino si no existe
if not exist "%DestinationFolder%" (
    mkdir "%DestinationFolder%"
)

# para generar un token en Settings > Developer Settings > Personal Access Token > Token (Classic)
set "repos="public^|https://github.com/cptsthecnical/Scripts/zipball/main public^|https://github.com/cptsthecnical/Technical-Documentation/zipball/main private^|https://github.com/cptsthecnical/prueba-privada/zipball/main"  

:: Descargar cada repo
for %%u in (%repos%) do (
    for /F "tokens=1,2 delims=^|" %%a in ("%%u") do (
        set "repoType=%%a"
        set "repoUrl=%%b"

        :: Extraer nombre del repositorio
        for /F "tokens=4 delims=/" %%c in ("!repoUrl!") do set "repoName=%%c"

        set "filePath=%DestinationFolder%\!repoName!.zip"

        echo =========================================
        echo Preparando !repoName!.zip...

        :: Intento de descarga
        if "!repoType!"=="public" (
            echo Visibilidad: !repoType!
            curl -L -o "!filePath!" "!repoUrl!" --silent
        ) else (
            echo Visibilidad: !repoType!
            curl -L -o "!filePath!" -H "Authorization: token %GitHubToken%" -H "User-Agent: curl" "!repoUrl!" --silent
        )

        :: Valido la descarga
        if exist "!filePath!" (
            echo [yes] - !repoName!.zip descargado en %DestinationFolder%
        ) else (
            echo [no] - Error al descargar !repoName!.zip
        )
    )
)

echo.
echo Descarga finalizada.
pause
