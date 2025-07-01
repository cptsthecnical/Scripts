#!/bin/bash
# 📝 este script se encarga de imprimir por consola los detalles del servidor de sistema, root, network, fylesystem, servicios, firewall

HOSTNAME=$(hostname)
OS_INFO=$(lsb_release -d 2>/dev/null | cut -f2- || grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d \")
ROOT_PASS="*********"
SSH_IP=$(ip addr show | grep -w inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1)
INTERFACES_FILE="/etc/network/interfaces"
IPTABLES_FILE="/etc/iptables/rules.v4"

IT_USERS=$(getent group sudo | cut -d: -f4)
ROOT_UID_USERS=$(awk -F: '($3 == 0) {print $1}' /etc/passwd)
PRIV_USERS=$(echo -e "$IT_USERS\n$ROOT_UID_USERS" | sort | uniq | grep -v '^$')

SERVICIOS=("ssh" "postfix" "iptables" "mariadb")

check_service() {
  systemctl is-active --quiet "$1" && echo "[*] $1"
}

echo "Sistema: $OS_INFO"
echo "Nombre de maquina: $HOSTNAME"
echo "Passwd de root: $ROOT_PASS"
if [ -n "$PRIV_USERS" ]; then
  echo "* Hay usuarios de IT con privilegios de root:"
  echo "$PRIV_USERS"
else
  echo "* No hay usuarios con privilegios root"
fi

echo
echo "Accesible por ssh desde: $SSH_IP"
echo
echo "===[ Network ]==================================================="
if [ -f "$INTERFACES_FILE" ]; then
  cat "$INTERFACES_FILE"
else
  echo "No se encontró $INTERFACES_FILE"
fi

echo
echo "===[ Filesystem ]==============================================="
df -h --output=source,fstype,size,used,avail,pcent,target

echo
echo "===[ Servicios ]================================================"
for svc in "${SERVICIOS[@]}"; do
  check_service "$svc"
done

echo
echo "===[ Firewall ]================================================="
if [ -f "$IPTABLES_FILE" ]; then
  cat "$IPTABLES_FILE"
else
  echo "No se encontró $IPTABLES_FILE"
fi

echo
echo "===[ Others ]==================================================="
echo "[Isaac ~ imp-srv.sh]: $(date '+%a %b %d %H:%M:%S %Z %Y')."
