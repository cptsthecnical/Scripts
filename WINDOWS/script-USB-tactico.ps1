## script para Windows en powershell para migrar con doble click mis apuntes públicos a un USB
## se recomienda utilizar el .bat en vez de el .ps1 porque en los active directory suele estar bloqueados los .ps1
# Configuración
$DestinationFolder = "E:\00-MANUALES"         # Cambiar por tu unidad USB
$GitHubToken = "TOKEN"                        # Solo necesario para repos privados
# para generar un token en Settings > Developer Settings > Personal Access Token > Token (Classic)
$repos = @(                             
    "https://github.com/aptelliot/Scripts/archive/refs/heads/main.zip",
    "https://github.com/aptelliot/Technical-Documentation/archive/refs/heads/main.zip",
    "https://github.com/aptelliot/prueba-privada/archive/refs/heads/main.zip"  
)

# Crear carpeta de destino si no existe
if (-not (Test-Path $DestinationFolder)) { New-Item -ItemType Directory -Path $DestinationFolder }

foreach ($repoUrl in $repos) {
    $repoName = ($repoUrl -split "/")[4]
    $fileName = "$repoName.zip"
    $filePath = Join-Path $DestinationFolder $fileName

    $descargado = $false

    # Intentar descarga pública
    try {
        Invoke-WebRequest -Uri $repoUrl -OutFile $filePath -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }
        if (Test-Path $filePath) {
            Write-Host "$fileName descargado públicamente en $DestinationFolder"
            $descargado = $true
        }
    }
    catch {
        Write-Host "No se pudo descargar públicamente $fileName"
    }

    # Si falla, intentar con token
    if (-not $descargado -and $GitHubToken -ne "") {
        Write-Host "Intentando descargar $fileName con token..."
        try {
            Invoke-WebRequest -Uri $repoUrl -OutFile $filePath -UseBasicParsing -Headers @{
                "Authorization" = "token $GitHubToken"
                "User-Agent"    = "Mozilla/5.0"
            }
            if (Test-Path $filePath) {
                Write-Host "$fileName descargado con token en $DestinationFolder"
            } else {
                Write-Host "Error: no se pudo descargar $fileName incluso con token"
            }
        }
        catch {
            Write-Host ('Excepción al descargar {0} con token: {1}' -f $fileName, $_.Exception.Message)
        }
    }
}
