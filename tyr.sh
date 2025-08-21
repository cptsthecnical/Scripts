#!/usr/bin/env bash
# 👢🐂🌵🐍	Murder On The Bayou
# 🧠 script de compilación genérica para Debian 
#   - Autor: Elliot (SysAdmin)
#   - Uso: ./tyr.sh <ruta_proyecto>

set -e
PROYECTO="${1:-.}"

# Función para Python
build_python() {
    echo "[+] Proyecto Python detectado"
    sudo apt update
    sudo apt install -y python3 python3-venv python3-pip
    cd "$PROYECTO"
    python3 -m venv venv
    source venv/bin/activate
    [ -f requirements.txt ] && pip install -r requirements.txt
    pip install pyinstaller
    MAIN=$(ls *.py | head -n1)
    pyinstaller --onefile "$MAIN"
    echo "[+] Binario Python generado en: dist/<paquete>"
    echo "[-] mover el binario a /usr/local/bin o alguna carpeta del PATH si quieres que sea ejecutable globalmente:"
    echo "    mv dist/<paquete> /usr/local/bin/"
    echo "    ./<paquete>"
    deactivate
}

# Función para C
build_c() {
    echo "[+] Proyecto C detectado"
    sudo apt update
    sudo apt install -y build-essential
    cd "$PROYECTO"
    for SRC in *.c; do
        BIN="${SRC%.c}"
        gcc "$SRC" -o "$BIN" -Wall -O2
        echo "[+] Compilado: $BIN"
    done
}

# Función para C++
build_cpp() {
    echo "[+] Proyecto C++ detectado"
    sudo apt update
    sudo apt install -y build-essential
    cd "$PROYECTO"
    for SRC in *.cpp; do
        BIN="${SRC%.cpp}"
        g++ "$SRC" -o "$BIN" -Wall -O2 -std=c++17
        echo "[+] Compilado: $BIN"
    done
}

# Función para Java
build_java() {
    echo "[+] Proyecto Java detectado"
    sudo apt update
    sudo apt install -y default-jdk
    cd "$PROYECTO"
    for SRC in *.java; do
        javac "$SRC"
        echo "[+] Compilado: ${SRC%.java}.class"
    done
    # Opcional: empaquetar en un JAR
    if ls *.class >/dev/null 2>&1; then
        jar cf app.jar *.class
        echo "[+] Empaquetado JAR: app.jar"
    fi
}

# Función para GO
build_go() {
    echo "[+] Proyecto Go detectado"
    sudo apt update
    sudo apt install -y golang-go
    cd "$PROYECTO"
    for SRC in *.go; do
        BIN="${SRC%.go}"
        go build -o "$BIN" "$SRC"
        echo "[+] Compilado: $BIN"
    done
}

# Función para Rust
build_rust() {
    echo "[+] Proyecto Rust detectado"
    sudo apt update
    sudo apt install -y rustc cargo
    cd "$PROYECTO"
    for SRC in *.rs; do
        BIN="${SRC%.rs}"
        rustc "$SRC" -o "$BIN"
        echo "[+] Compilado: $BIN"
    done
}

# Detección de proyecto
cd "$PROYECTO"

if ls *.py >/dev/null 2>&1 || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
    build_python
elif ls *.c >/dev/null 2>&1; then
    build_c
elif ls *.cpp >/dev/null 2>&1; then
    build_cpp
elif ls *.java >/dev/null 2>&1; then
    build_java
elif ls *.rs >/dev/null 2>&1; then
    build_rust
elif ls *.go >/dev/null 2>&1; then
    build_go
else
    echo "[!] No se detecta proyecto Python, C, C++ ni Java en $PROYECTO"
    exit 1
fi
