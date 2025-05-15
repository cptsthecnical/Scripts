#!/bin/bash

# ¿Que es? :: Terrapin es una vulnerabilidad en el protocolo SSH (en ciertos Kex como "ChaCha20-Poly1305") que permite manipular el canal de comunicación antes de la autenticación, rompiendo la integridad de la sesión.
# Uso      :: Lanzo el script ./script-terrapin.py y me pedirá agregar la ip y el usuario de la máquina a atacar.
 read -p "Introduce la IP del servidor: " IP
 read -p "Introduce el nombre de usuario: " USER

 OUTPUT=$(ssh -vvv -oBatchMode=yes -oConnectTimeout=5 \
     -oKexAlgorithms=curve25519-sha256 \
     -oCiphers=chacha20-poly1305@openssh.com \
     -oMACs=hmac-sha2-256-etm@openssh.com \
     "$USER@$IP" exit 2>&1)

 VULNERABLE=0

 if echo "$OUTPUT" | grep -q "no matching kex algorithm"; then
     echo "✅ NO vulnerable (rechaza Kex inseguro)"
 else
     echo "❎ VULNERABLE (acepta Kex inseguro)"
     VULNERABLE=1
 fi

 if echo "$OUTPUT" | grep -q "no matching cipher"; then
     echo "✅ NO vulnerable (rechaza Cipher inseguro)"
 else
     echo "❎ VULNERABLE (acepta Cipher inseguro)"
     VULNERABLE=1
 fi

 if echo "$OUTPUT" | grep -q "no matching MAC found"; then
     echo "✅ NO vulnerable (rechaza MAC inseguro)"
 else
     echo "❎ VULNERABLE (acepta MAC inseguro)"
     VULNERABLE=1
 fi

 if [ $VULNERABLE -eq 0 ]; then
     echo "✅ Servidor seguro contra Terrapin."
 else
     echo "❌ Servidor vulnerable a Terrapin."
 fi

# ============================================================================================
# [🐍 SOLUCIÓN DE VULNERABILIDAD]:
# https://terrapin-attack.com/
# Vulnerabilidad CVE: CVE-2023-48795 
# Terrapin actua en ssh sobre Kex, cipher y MAC:
#     + Solo usar Kex seguros y modernos.
#     + Cifrar con AES-GCM (evita ChaCha20 y DH débiles).
#     + Usar MACs con protección EtM y SHA-2.
#
# Para saber qué ciphers, KEX y MACs tiene habilitados tu servidor SSH (OpenSSH):
# > sshd -T | grep ciphers && sshd -T | grep kexalgorithms && sshd -T | grep macs
#
# Para saber qué algoritmos soporta tu cliente SSH:
# > ssh -Q cipher && ssh -Q kex && ssh -Q mac
#
#
# > vim /etc/ssh/sshd_config
# --------------------------------------------------------------------------------------------
# Fuerza solo KEX seguros y con mitigación Terrapin
# > KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512
# > MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
# Evita ciphers afectados
# > Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com
# --------------------------------------------------------------------------------------------
# > systemctl restart ssh
# ============================================================================================
