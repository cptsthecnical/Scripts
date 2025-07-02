#!/bin/bash
# 📝 este script se encarga de imprimir por consola los detalles del servidor de sistema, root, network, fylesystem, servicios, firewall
YELLOW='\033[1;33m'
NC='\033[0m'
   
HOSTNAME=$(hostname)
OS_INFO=$(lsb_release -d 2>/dev/null | cut -f2- || grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d \")
ROOT_PASS="<PASSWORD_ROOT>"
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

check_ipv6() {
   if lsmod | grep -q '^ipv6'; then
     echo "habilitado"
   else
     echo "deshabilitado"
   fi
}

echo -e "${YELLOW}Sistema:${NC} $OS_INFO"
echo -e "${YELLOW}Nombre de maquina:${NC} $HOSTNAME"
echo -e "${YELLOW}Passwd de root:${NC} $ROOT_PASS"
if [ -n "$PRIV_USERS" ]; then
  echo "* Hay usuarios de IT con privilegios de root:"
  echo "$PRIV_USERS"
else
  echo "* No hay usuarios con privilegios root"
fi

echo
echo -e "${YELLOW}IPv6:${NC} $(check_ipv6)"
echo -e "${YELLOW}Accesible por ssh desde:${NC} $SSH_IP"
echo
echo -e "${YELLOW}===[ Network ]===================================================${NC}"
if [ -f "$INTERFACES_FILE" ]; then
  cat "$INTERFACES_FILE"
else
  echo "No se encontró $INTERFACES_FILE"
fi

echo
echo -e "${YELLOW}===[ Filesystem ]===============================================${NC}"
df -h --output=source,fstype,size,used,avail,pcent,target

echo
echo -e "${YELLOW}===[ Servicios ]================================================${NC}"
for svc in "${SERVICIOS[@]}"; do
  check_service "$svc"
done

echo
echo -e "${YELLOW}===[ Firewall ]=================================================${NC}"
if [ -f "$IPTABLES_FILE" ]; then
  cat "$IPTABLES_FILE"
else
  echo "No se encontró $IPTABLES_FILE"
fi

echo
echo -e "${YELLOW}===[ Others ]===================================================${NC}"
echo "[Isaac ~ imp-srv.sh]: $(date '+%a %b %d %H:%M:%S %Z %Y')."
echo ""
