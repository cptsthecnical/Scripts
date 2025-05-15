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

if echo "$OUTPUT" | grep -q "no matching kex algorithm"; then
    echo "[✔] NO vulnerable (rechaza Kex inseguro)"
elif echo "$OUTPUT" | grep -q "no matching cipher"; then
    echo "[✔] NO vulnerable (rechaza Cipher inseguro)"
elif echo "$OUTPUT" | grep -q "no matching MAC found"; then
    echo "[✔] NO vulnerable (rechaza MAC inseguro)"
elif echo "$OUTPUT" | grep -q "Connection established"; then
    echo "[!] VULNERABLE a Terrapin (algoritmos inseguros aceptados)"
else
    echo "[?] No se pudo determinar con certeza. Revisa manualmente:"
    echo "$OUTPUT" | tail -n 10
fi

# ============================================================================================
# [🐍 SOLUCIÓN DE VULNERABILIDAD]:
# > vim /etc/ssh/sshd_config
# --------------------------------------------------------------------------------------------
# Fuerza solo KEX seguros y con mitigación Terrapin
# > KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512
# > MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
# Evita ciphers afectados
# > Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com
# --------------------------------------------------------------------------------------------
# > systemctl restart ssh
