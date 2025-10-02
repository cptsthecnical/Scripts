## script para Windows en powershell para migrar con doble click mis apuntes a un USB
# Configuración
$GitHubUser = "TU_USUARIO"
$Token = "TU_TOKEN"         # ⚠️ Mantener seguro
$DestinationFolder = "E:\"  # ⚠️ Cambiar por la unidad usb

# Crear carpeta de destino si no existe
if (-not (Test-Path $DestinationFolder)) { New-Item -ItemType Directory -Path $DestinationFolder }

# Lista de repositorios a clonar (pueden ser privados o públicos)
$repos = @(
    "https://github.com/aptelliot/Technical-Documentation",
    "https://github.com/aptelliot/Scripts",
    "https://github.com/aptelliot/repo-prueba"
)

foreach ($repoUrl in $repos) {
    # Extraer nombre del repositorio
    $repoName = ($repoUrl -split "/")[-1]
    $repoPath = Join-Path $DestinationFolder $repoName

    # Insertar token para repos privados
    $cloneUrl = $repoUrl -replace "https://", "https://$GitHubUser`:$Token@"

    if (-not (Test-Path $repoPath)) {
        Write-Host "Clonando $repoName..."
        git clone $cloneUrl $repoPath
    } else {
        Write-Host "Actualizando $repoName..."
        git -C $repoPath pull
    }
}
