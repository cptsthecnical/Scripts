#!/bin/bash
# 🧠 Con este script comprueba si el correo pasado es real y existe

# Función para comprobar si swaks está instalado
function check_swaks {
  if ! command -v swaks &> /dev/null; then
    echo "swaks no está instalado."
    read -p "¿Quieres instalar swaks ahora? (s/n): " install_choice
    if [[ "$install_choice" =~ ^[Ss]$ ]]; then
      if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y swaks
      elif command -v yum &> /dev/null; then
        sudo yum install -y swaks
      else
        echo "No se pudo detectar gestor de paquetes compatible. Instala swaks manualmente."
        exit 1
      fi
    else
      echo "swaks es necesario para continuar. Saliendo."
      exit 1
    fi
  fi
}

# Función para validar correo con swaks
function validate_email {
  local email=$1
  local domain="${email#*@}"

  # Obtener servidor MX
  local mxserver=$(dig +short MX "$domain" | sort -n | head -1 | awk '{print $2}' | sed 's/\.$//')

  if [ -z "$mxserver" ]; then
    echo "No se pudo obtener servidor MX para $domain"
    exit 1
  fi

  echo "Usando servidor MX: $mxserver"

  local output=$(swaks --to "$email" --server "$mxserver" --quit-after RCPT 2>&1)

  # Mejor chequeo de respuesta
  if echo "$output" | grep -qE "250 2.1.5|250 Ok"; then
    echo "Correo válido o aceptado por el servidor."
  elif echo "$output" | grep -q "550"; then
    echo "Correo rechazado (no existe)."
  else
    echo "Respuesta del servidor no concluyente:"
    echo "$output"
  fi
}

# --- Script principal ---

check_swaks

read -p "Introduce el correo a validar: " user_email

validate_email "$user_email"
