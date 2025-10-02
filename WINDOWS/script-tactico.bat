@echo off
setlocal enabledelayedexpansion

:: script para Windows en CMD para migrar con doble click mis apuntes públicos a un USB
:: Configuración
set "DestinationFolder=E:\"
set "GitHubToken=TOKEN"  


:: Crear carpeta de destino si no existe
if not exist "%DestinationFolder%" (
    mkdir "%DestinationFolder%"
)

:: Lista de repositorios
set "repos=https://github.com/aptelliot/Scripts/archive/refs/heads/main.zip https://github.com/aptelliot/Technical-Documentation/archive/refs/heads/main.zip https://github.com/aptelliot/prueba-privada/archive/refs/heads/main.zip"

:: Descargar cada repo
for %%u in (%repos%) do (
    set "repoUrl=%%u"
    
    :: Extraer nombre del repositorio (4º token)
    for /F "tokens=4 delims=/" %%a in ("!repoUrl!") do set "repoName=%%a"

    set "filePath=%DestinationFolder%\!repoName!.zip"

    echo Descargando !repoName!.zip...

    :: Intento de descarga pública
    curl -L -o "!filePath!" "!repoUrl!" --silent
    if exist "!filePath!" (
        echo !repoName!.zip descargado públicamente en %DestinationFolder%
    ) else (
        if not "%GitHubToken%"=="" (
            echo No se pudo descargar públicamente !repoName!.zip
            echo Intentando con token...
            curl -L -o "!filePath!" -H "Authorization: token %GitHubToken%" -H "User-Agent: curl" "!repoUrl!" --silent
            if exist "!filePath!" (
                echo !repoName!.zip descargado con token en %DestinationFolder%
            ) else (
                echo Error: no se pudo descargar !repoName!.zip incluso con token
            )
        ) else (
            echo Error: no se pudo descargar !repoName!.zip y no hay token
        )
    )
)

echo Descarga finalizada.
pause
