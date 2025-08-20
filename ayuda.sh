#!/bin/bash
YELLOW="\e[33m"
RESET="\e[0m"

printf "%b\n" "\

# snmp
${YELLOW}snmpwalk -v2c -c <COMMUNITY-SNMP> -Oneq <IP-SNMP> .1 > dc1-kvm1.snmpwalk${RESET}                 - Exporta árbol SNMP completo al archivo dc1-kvm1.snmpwalk.

# archivos
${YELLOW}rsync -avzc --progress /ruta/origen/ usuario@host:/ruta/destino/${RESET}                         - Copia eficiente de Linux a Linux, mantiene permisos y metadatos (usuarios, hard-links...).
${YELLOW}scp -r /ruta/origen/ usuario@host:/ruta/destino/${RESET}                                         - Copia directa pero más lenta, ideal usando Windows, si Windows no tiene rsync.
${YELLOW}chattr +i /ruta/origen/documento.txt${RESET}                                                     - Establece atributo inmutable (impide modificar/borrar el archivo, -i para revertirlo).

# compresión
${YELLOW}tar -czvf prueba.tar.gz comprimir/${RESET}                                                        - Comprime carpeta con gzip.
${YELLOW}tar -xzvf prueba.tar.gz${RESET}                                                                   - Extrae contenido si fue comprimido con gzip.

# samba
${YELLOW}smbstatus | grep \"nombre_del_archivo.xls\"${RESET}                                                 - Verifica si un archivo está abierto por Samba (lo detengo con kill -9).
${YELLOW}smbstatus -L${RESET}                                                                              - Lista todos los archivos abiertos vía Samba con usuarios y PIDs.

# forense
${YELLOW}lsblk -e7 -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINT,FSTYPE,MODEL,MODE,STATE,VENDOR,UUID'${RESET} - Muestra información detallada de los dispositivos de bloques detectados.
${YELLOW}hdparm -I /dev/sda3${RESET}                                                                       - Muestra capacidades del disco/SSD (modelo, firmware, modos DMA/UDMA, velocidades, características SMART soportadas, límites de seguridad, etc.).
${YELLOW}smartctl -axH /dev/sda3${RESET}                                                                   - Muestra todo SMART (atributos, historial de errores, tests) -x (tablas y logs vendor-specific), -H (salud PASSED/FAILED).

# redes
${YELLOW}nmap -p- --open -T5 -v -n [Ip Víctima] -oG [Nombre del archivo de guardado.]${RESET}              - nmap: escanea todos los puertos de la victima. Parámetros opcionales (-oG) lo guarda en el archivo índicado, (-n) no muestra los DNS.
${YELLOW}curl ifconfig.es${RESET}                                                                          - curl: muestra la ip pública (también existe ifconfig.me).
${YELLOW}tcpdump -i ens33 -nn host [Ip Host]${RESET}                                                       - tcpdump: captura en eth0 todo el tráfico IP hacia o desde 192.168.1.1, con -nn cambia el nombre puertos y servicio por números (https por 443).
${YELLOW}netstat -nlpt${RESET}                                                                             - netstat: muestra qué procesos están escuchando en qué puertos TCP de tu máquina, con su PID correspondiente.
${YELLOW}tcpdump${RESET}                                                                                   - tcpdump: captura y analiza paquetes que permite inspeccionar el tráfico de red que atraviesa una interfaz.
${YELLOW}nslookup${RESET}                                                                                  - nslookup: resuelve nombres DNS a direcciones IP (y viceversa).
${YELLOW}ss${RESET}                                                                                        - ss: muestra sockets/ conexiones de red (puertos, estados, procesos asociados).
${YELLOW}ps aux --sort=-%cpu | head -n 20${RESET}                                                          - ps -aux: instantánea estática de todos los procesos.

"
