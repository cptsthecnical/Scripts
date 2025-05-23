#!/usr/bin/env python3
# 🧠 Radar Security:
# 🧠 Evalúa actualizaciones pendientes, permisos de archivos críticos, configuración SSH, firewall, usuarios sin contraseña,
# 🧠 seguridad del kernel y configuraciones adicionales.

import os
import subprocess
import stat

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

def check_kernel_security():
    print("Comprobando configuraciones de seguridad del kernel...")
    try:
        # Verificar si KASLR (Kernel Address Space Layout Randomization) está habilitado
        result = subprocess.run(['sysctl', 'kernel.randomize_va_space'], capture_output=True, text=True)
        if "2" in result.stdout:
            print("✅ KASLR está habilitado.")
        else:
            print(f"{RED}Advertencia: KASLR no está habilitado.{RESET}")

        # Verificar si KPTI (Kernel Page Table Isolation) está habilitado
        result = subprocess.run(['sysctl', 'kernel.page-table-isolation'], capture_output=True, text=True)
        if "1" in result.stdout:
            print("✅ KPTI está habilitado.")
        else:
            print(f"{RED}Advertencia: KPTI no está habilitado.{RESET}")
    except Exception as e:
        print(f"Error al comprobar configuraciones de seguridad del kernel: {e}")

def check_cron_permissions():
    cron_dirs = ['/etc/cron.d', '/etc/cron.daily', '/etc/cron.weekly', '/etc/cron.monthly']
    for dir in cron_dirs:
        try:
            st = os.stat(dir)
            mode = stat.S_IMODE(st.st_mode)
            if mode != 0o700:  # Verifica que los permisos sean 700
                print(f"⚠️  {dir} tiene permisos {oct(mode)}. Se recomienda {oct(0o700)}.")
            else:
                print(f"✅ {dir} tiene permisos correctos.")
        except Exception as e:
            print(f"Error al verificar {dir}: {e}")

def check_suid_sgid():
    print("Comprobando archivos con SUID/SGID:")
    try:
        result = subprocess.run(['find', '/', '-type', 'f', '-perm', '/6000'], capture_output=True, text=True)
        if result.stdout:
            print(f"⚠️  Archivos con SUID/SGID encontrados:\n{result.stdout}")
        else:
            print("✅ No se encontraron archivos con SUID/SGID.")
    except Exception as e:
        print(f"Error al comprobar archivos con SUID/SGID: {e}")

def check_unnecessary_services():
    print("Comprobando servicios innecesarios:")
    try:
        result = subprocess.run(['systemctl', 'list-units', '--type=service', '--state=running'], capture_output=True, text=True)
        if result.stdout:
            print(f"⚠️  Servicios en ejecución:\n{result.stdout}")
            # Aquí puedes agregar lógica para deshabilitar servicios innecesarios
        else:
            print("✅ No se encontraron servicios en ejecución.")
    except Exception as e:
        print(f"Error al comprobar servicios innecesarios: {e}")

def check_listening_ports():
    print("Comprobando puertos de red escuchando:")
    try:
        result = subprocess.run(['ss', '-tuln'], capture_output=True, text=True)
        if result.stdout:
            print(f"⚠️  Puertos de red escuchando:\n{result.stdout}")
        else:
            print("✅ No se encontraron puertos de red escuchando.")
    except Exception as e:
        print(f"Error al comprobar puertos de red escuchando: {e}")

def main():
    check_updates()
    print("🔐 Verificando archivos y directorios críticos:")
    check_permissions('/etc/passwd', 0o644, 'root', 'root')
    check_permissions('/etc/shadow', 0o600, 'root', 'shadow')
    check_permissions('/etc/sudoers', 0o440, 'root', 'root')
    check_permissions('/tmp', 0o1777, 'root', 'root')
    check_ssh_config()
    check_firewall()
    check_empty_passwords()
    check_kernel_security()
    check_cron_permissions()
    check_suid_sgid()
    check_unnecessary_services()
    check_listening_ports()

if __name__ == "__main__":
    main()
