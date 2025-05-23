#!/usr/bin/env python3
# 🧠 Script Radar Security
# 🧠 Evalua actualizaciones pendientes, permisos de archivos críticos y directorios, configuración SSH, firewall, usuarios sin contraseña, 

import os
import stat
import subprocess

# Códigos de escape ANSI para colores
RED = "\033[91m"
RESET = "\033[0m"

def check_updates():
    print("Comprobando actualizaciones de seguridad...")
    try:
        result = subprocess.run(['apt', 'list', '--upgradable'], capture_output=True, text=True)
        if "upgradable" in result.stdout:
            print(f"{RED}Se encontraron actualizaciones disponibles:{RESET}")
            print(result.stdout)
        else:
            print("No hay actualizaciones disponibles.")
    except Exception as e:
        print(f"Error al comprobar actualizaciones: {e}")

def check_permissions(path, expected_mode, expected_owner, expected_group):
    try:
        st = os.stat(path)
        mode = stat.S_IMODE(st.st_mode)
        uid = st.st_uid
        gid = st.st_gid
        actual_owner = subprocess.getoutput(f'stat -c %U {path}')
        actual_group = subprocess.getoutput(f'stat -c %G {path}')
        if mode != expected_mode or actual_owner != expected_owner or actual_group != expected_group:
            print(f"⚠️  {path} tiene permisos {oct(mode)}, propietario {actual_owner}:{actual_group}. Se recomienda {oct(expected_mode)} {expected_owner}:{expected_group}.")
        else:
            print(f"✅ {path} tiene permisos y propietario correctos.")
    except Exception as e:
        print(f"Error al verificar {path}: {e}")

def check_ssh_config():
    path = '/etc/ssh/sshd_config'
    try:
        with open(path, 'r') as f:
            config = f.read()
            if 'PermitRootLogin yes' in config:
                print(f"⚠️  {path} permite el acceso directo de root. Se recomienda establecer 'PermitRootLogin no'.")
            else:
                print(f"✅ {path} tiene una configuración segura para 'PermitRootLogin'.")
    except Exception as e:
        print(f"Error al verificar {path}: {e}")

def check_firewall():
    print("Comprobando estado del firewall (UFW)...")
    try:
        result = subprocess.run(['ufw', 'status'], capture_output=True, text=True)
        if "inactive" in result.stdout:
            print(f"{RED}Advertencia: El firewall UFW está desactivado.{RESET}")
        else:
            print("El firewall UFW está activo.")
    except Exception as e:
        print(f"Error al comprobar el estado del firewall UFW: {e}")

    print("Comprobando reglas de iptables...")
    try:
        result = subprocess.run(['iptables', '-L'], capture_output=True, text=True)
        if "Chain" not in result.stdout:
            print(f"{RED}Advertencia: No hay reglas configuradas en iptables.{RESET}")
        else:
            print("Reglas de iptables configuradas:")
            print(result.stdout)
    except Exception as e:
        print(f"Error al comprobar iptables: {e}")

def check_empty_passwords():
    print("Comprobando usuarios sin contraseña...")
    try:
        result = subprocess.run(['awk', '-F:', '($2==""){print $1}', '/etc/shadow'], capture_output=True, text=True)
        if result.stdout:
            print(f"{RED}Advertencia: Los siguientes usuarios no tienen contraseña:{RESET}")
            print(result.stdout.strip())
        else:
            print("No hay usuarios sin contraseña.")
    except Exception as e:
        print(f"Error al comprobar usuarios sin contraseña: {e}")

def main():
    check_updates()
    print("🔐 Verificando archivos y directorios críticos:")
    check_permissions('/etc/passwd', 0o644, 'root', 'root')
    check_permissions('/etc/shadow', 0o640, 'root', 'shadow')
    check_permissions('/etc/sudoers', 0o440, 'root', 'root')
    check_permissions('/tmp', 0o1777, 'root', 'root')
    check_ssh_config()
    check_firewall()
    check_empty_passwords()

if __name__ == "__main__":
    main()

# ============================================================================================
# [🐍 SOLUCIÓN DE VULNERABILIDAD]:
# evalua los siguientes datos:
#   + Actualizaciones
#   + permisos de archivos
#      - /etc/passwd
#      - /etc/shadow
#      - /etc/sudoers
#      - /tmp
#   + Configuración SHH
#   + Firewall
#      - ufw
#      - iptables
#
# [🐍 EJECUTAR SCRIPT]:
# chmod 700 RS-807.py
# ./RS-807.py
# ============================================================================================
