## script para Windows en powershell para migrar con doble click mis apuntes públicos a un USB
# Configuración
$DestinationFolder = "F:\repositorio\"      # Cambiar por tu unidad USB
$repos = @(
    "https://github.com/aptelliot/Scripts/archive/refs/heads/main.zip",
    "https://github.com/aptelliot/Technical-Documentation/archive/refs/heads/main.zip"
)

# Crear carpeta de destino si no existe
if (-not (Test-Path $DestinationFolder)) { New-Item -ItemType Directory -Path $DestinationFolder }

foreach ($repoUrl in $repos) {
    # Extraer nombre del repositorio de la URL
    $repoName = ($repoUrl -split "/")[4]    # 0=https:, 1=, 2=github.com, 3=usuario, 4=repo
    $fileName = "$repoName.zip"             # Usamos el nombre del repo en vez de main.zip
    $filePath = Join-Path $DestinationFolder $fileName

    Write-Host "Descargando $fileName..."
    try {
        Invoke-WebRequest -Uri $repoUrl -OutFile $filePath -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }
        if (Test-Path $filePath) {
            Write-Host "$fileName descargado correctamente en $DestinationFolder"
        } else {
            Write-Host "Error: no se pudo descargar $fileName"
        }
    }
    catch {
        Write-Host ('Excepción al descargar {0}: {1}' -f $fileName, $_.Exception.Message)
    }
}
