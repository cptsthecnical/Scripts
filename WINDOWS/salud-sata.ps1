# Lista discos y su estado
Get-PhysicalDisk | Select-Object FriendlyName, DeviceId, MediaType, OperationalStatus, HealthStatus, Size

# Información SMART básica vía WMI
Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus |
Select-Object InstanceName, PredictFailure, Reason

# Información SMART avanzada (sectores reasignados, temperatura) si el disco lo soporta
Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictData |
ForEach-Object {
    $drive = $_.InstanceName
    $rawData = $_.VendorSpecific
    [PSCustomObject]@{
        Drive = $drive
        ReallocatedSectorsCount = $rawData[5]  # ejemplo índice típico, puede variar según fabricante
    }
}
