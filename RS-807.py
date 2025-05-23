#!/usr/bin/env python3
# 🧠 Script Radar Security
# 🧠 Evalua actualizaciones pendientes, permisos de archivos críticos y directorios, configuración SSH, firewall, usuarios sin contraseña, 

import os
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

def check_root_permissions():
    print("Comprobando permisos de archivos críticos...")
    critical_files = ['/etc/passwd', '/etc/shadow', '/etc/sudoers']
    for file in critical_files:
        permissions = os.stat(file).st_mode
        if permissions & 0o777 != 0o600:  # Verifica que los permisos sean 600
            print(f"{RED}Advertencia: Los permisos de {file} no son seguros.{RESET}")
        else:
            print(f"Los permisos de {file} son seguros.")

def check_tmp_permissions():
    print("Comprobando permisos del directorio /tmp...")
    tmp_permissions = os.stat('/tmp').st_mode
    if tmp_permissions & 0o777 != 0o177:  # Verifica que los permisos sean 1777
        print(f"{RED}Advertencia: Los permisos de /tmp no son seguros.{RESET}")
    else:
        print("Los permisos de /tmp son seguros.")
        
def check_ssh_config():
    print("Comprobando configuración de SSH...")
    ssh_config = '/etc/ssh/sshd_config'
    if os.path.exists(ssh_config):
        with open(ssh_config, 'r') as file:
            config = file.read()
            if 'PermitRootLogin yes' in config:
                print(f"{RED}Advertencia: PermitRootLogin está habilitado.{RESET}")
            else:
                print("La configuración de SSH es segura.")
    else:
        print("No se encontró el archivo de configuración de SSH.")

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
    check_root_permissions()
    check_tmp_permissions()
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
