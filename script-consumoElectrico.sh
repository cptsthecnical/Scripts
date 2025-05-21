#!/bin/bash
# Verificar si powertop está instalado
if ! command -v powertop >/dev/null 2>&1; then
    read -p "Powertop no está instalado. ¿Quieres instalarlo? (s/n): " opcion
    if [[ "$opcion" == "s" || "$opcion" == "S" ]]; then
        sudo apt update && sudo apt install -y powertop
    else
        echo "No se puede continuar sin powertop. Saliendo..."
        exit 1
    fi
fi

# Ejecutar powertop y obtener consumo total
POWER=$(sudo powertop --time=1 --csv=/tmp/power.csv > /dev/null && grep -m1 "Total" /tmp/power.csv | awk -F',' '{print $2}' | tr -d ' W')

# Timestamp actual
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
MENSAJE="[$TIMESTAMP] Consumo total: $POWER W"

# Enviar al log del sistema
logger -t powertop-log "$MENSAJE"

# Mostrar en pantalla
echo "$MENSAJE"

# *************************************************************
# Ejemplo cada 5 minutos:
# sudo crontab -e
# */5 * * * * /ruta/completa/log_powertop.sh
