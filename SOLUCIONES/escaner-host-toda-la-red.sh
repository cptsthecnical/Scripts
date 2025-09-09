#!/bin/bash
# este script escanea toda la red en busca de los equipos, imprimiendo su ip y su host
# Pedir la red al usuario
read -p "Introduce la red /24 (ej: 192.168.1): " network

echo "Escaneando la red $network.0/24..."

for i in {1..254}; do
    ip="$network.$i"
    host=$(dig -x $ip +short)
    if [ -n "$host" ]; then
        echo "$ip -> $host"
    fi
done

echo "Escaneo completado."
