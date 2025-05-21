#!/bin/bash
# Archivo de log
LOGFILE="powertop_log.csv"

# Cabecera si el archivo no existe
if [ ! -f "$LOGFILE" ]; then
    echo "Timestamp,Power_Watts" > "$LOGFILE"
fi

# Ejecutar powertop, extraer línea de consumo total
POWER=$(sudo powertop --time=1 --csv=/tmp/power.csv > /dev/null && grep -m1 "Total" /tmp/power.csv | awk -F',' '{print $2}' | tr -d ' W')

# Timestamp actual
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Guardar en CSV
echo "$TIMESTAMP,$POWER" >> "$LOGFILE"

# *************************************************************
# Ejemplo cada 5 minutos:
# sudo crontab -e
# */5 * * * * /ruta/completa/log_powertop.sh
