#!/bin/bash
# 🧠 Script para crear un usuario con permisos root (UID 0).
# 🧠 Pide nombre, comentario, contraseña y opcionalmente crea enlaces simbólicos desde root.
# ⚠️ Useradd warning: es una advertencia de que se esta utilizando el UID 0 (root).

read -p "¿Quieres crear un usuario con privilegios root? [s/N]: " confirmar
[[ "$confirmar" != "s" && "$confirmar" != "S" ]] && {
  echo "Cancelado."
  exit 1
}

read -p "Introduce el nombre del nuevo usuario: " usuario
read -p "Introduce el comentario para el usuario (ej. 'Nombre Apellido - Rol'): " comentario

# Leer contraseña sin mostrarla
read -s -p "Introduce la contraseña del nuevo usuario: " pass1
echo
read -s -p "Confirma la contraseña: " pass2
echo

if [[ "$pass1" != "$pass2" ]]; then
  echo "❌ Las contraseñas no coinciden. Abortando."
  exit 1
fi

# Crear usuario con UID y GID 0
sudo useradd \
  --comment "$comentario" \
  --uid 0 \
  --gid 0 \
  --non-unique \
  --shell /bin/bash \
  --create-home \
  "$usuario"

# Asignar contraseña ingresada
echo "$usuario:$pass1" | sudo chpasswd

# Preguntar si se deben crear los enlaces simbólicos desde /root
read -p "¿Deseas crear enlaces simbólicos de los archivos de configuración de root (.bashrc, .vimrc y .selected_editor)? [s/N]: " enlazar
if [[ "$enlazar" == "s" || "$enlazar" == "S" ]]; then
  sudo ln -sf /root/.bashrc "/home/$usuario/.bashrc"
  sudo ln -sf /root/.vimrc "/home/$usuario/.vimrc"
  sudo ln -sf /root/.selected_editor "/home/$usuario/.selected_editor"
  echo "✅ Enlaces simbólicos creados."
else
  echo "ℹ️ No se crearon enlaces simbólicos."
fi

# Asegurar propiedad del directorio home
sudo chown -R root:root "/home/$usuario"

echo "✅ Usuario '$usuario' creado con UID 0 y contraseña asignada."
