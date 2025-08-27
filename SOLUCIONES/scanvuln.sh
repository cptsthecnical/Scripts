#!/bin/bash

# Comprobación de Nmap
if ! command -v nmap &>/dev/null; then
  read -rp "[!] Nmap no está instalado. ¿Quieres instalarlo? (s/n): " respuesta
  if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    echo "[*] Instalando nmap..."
    sudo apt update && sudo apt install -y nmap
    if [[ $? -ne 0 ]]; then
      echo "[!] Error al instalar nmap."
      exit 1
    fi
  else
    echo "[!] Nmap es necesario para realizar el escaneo."
    exit 1
  fi
fi

# Verificar parámetro
if [[ -z "$1" ]]; then
  echo "================================================================================"
  echo "Uso: scanvuln <IP>"        # escaneo de servicios y vulnerabilidades usando Nmap        
  echo " "
  exit 1
fi

ip="$1"
echo "[*] Escaneando la IP $ip con Nmap + scripts de vulnerabilidades..."
sudo nmap -sV --script vuln "$ip"
