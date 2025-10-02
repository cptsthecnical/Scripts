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

:: Lista de repositorios (formato: tipo^|url-github/zipball/main) 
set "repos=public^|https://github.com/aptelliot/Scripts/zipball/main public^|https://github.com/aptelliot/Technical-Documentation/zipball/main private^|https://api.github.com/repos/aptelliot/prueva-repositorio-privado/zipball/main"

:: Descargar cada repo
for %%u in (%repos%) do (
    for /F "tokens=1,2 delims=^|" %%a in ("%%u") do (
        set "repoType=%%a"
        set "repoUrl=%%b"

        :: Extraer nombre del repositorio si es publico o privado
        if "!repoType!"=="public" (
            for /F "tokens=4 delims=/" %%c in ("!repoUrl!") do set "repoName=%%c"
        ) else (
            for /F "tokens=5 delims=/" %%c in ("!repoUrl!") do set "repoName=%%c"
        )

        set "filePath=%DestinationFolder%\!repoName!.zip"

        echo =========================================
        echo Preparando !repoName!.zip...

        :: Intento de descarga
        if "!repoType!"=="public" (
            curl -L -o "!filePath!" "!repoUrl!" --silent
        ) else (
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
