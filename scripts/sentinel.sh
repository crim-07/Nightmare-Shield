#!/bin/bash

echo "Sentinel Shield - SOC AI Agent (Powered by AMD HawkPoint)"
echo "-----------------------------------------------------------"
echo "[*] Consultando telemetría distribuida en la malla..."

SSH_OPTS="-o ConnectTimeout=3 -o BatchMode=yes -i ~/.ssh/ansible_sentinel"

# --- 1. DOCKER (yotsugi-3 y Lenovo - root/tohka) ---
D_YOTSUGI=$(ssh $SSH_OPTS root@yotsugi-3 "/usr/bin/docker ps --format '{{.Names}}'" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
D_LENOVO=$(ssh $SSH_OPTS tohka@100.70.221.63 "/usr/bin/docker ps --format '{{.Names}}'" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
DOCKER_TOTAL=$(echo "$D_YOTSUGI,$D_LENOVO" | sed 's/^,//;s/,,/,/;s/,$//')

# --- 2. PROXMOX / PCT (HP Compaq - root) ---
LXC_PROXMOX=$(ssh $SSH_OPTS root@100.84.165.74 "/usr/sbin/pct list" 2>/dev/null | awk 'NR>1 {print $3}' | tr '\n' ',' | sed 's/,$//')

# --- 3. LXC EDGE (HP G7 y Gateway - root) ---
LXC_HP_G7=$(ssh $SSH_OPTS root@100.80.213.127 "/usr/bin/lxc-ls --active -1" 2>/dev/null | tr '\n' ',')
LXC_GATEWAY=$(ssh $SSH_OPTS root@10.0.1.2 "/usr/bin/lxc-ls --active -1" 2>/dev/null | tr '\n' ',')
LXC_EXT=$(echo "$LXC_HP_G7$LXC_GATEWAY" | sed 's/,$//')

# Limpieza de la lista nominal de contenedores
CONTENEDORES_LISTA=$(echo "$DOCKER_TOTAL,$LXC_PROXMOX,$LXC_EXT" | sed 's/^,//; s/,$//; s/,,/,/g')
[ -z "$CONTENEDORES_LISTA" ] || [ "$CONTENEDORES_LISTA" == "," ] && CONTENEDORES_LISTA="Ninguno activo"

# --- 4. TELEMETRÍA LOCAL ---
PEERS_ONLINE=$(tailscale status | grep -c "active" 2>/dev/null)
LOCAL_LOGS=$(journalctl -n 5 --no-pager 2>/dev/null | cut -d ' ' -f 5-15)

CONTEXTO="
DISPOSITIVOS: Asus Tuf , HP Compaq , Lenovo Ideapad, HP G7 , Gateway.
RED MESH: $PEERS_ONLINE nodos activos.
CONTENEDORES ACTIVOS DETECTADOS: $CONTENEDORES_LISTA
LOGS RECIENTES: $LOCAL_LOGS"

echo "[*] Motor Phi-3 analizando infraestructura sobre Ryzen 7 260..."

PAYLOAD=$(jq -n --arg ctx "$CONTEXTO" '{
  "model": "phi3",
  "stream": false,
  "options": { "temperature": 0.0, "num_predict": 350, "num_ctx": 4096 },
  "prompt": "Eres un analista SOC Senior. Tu respuesta debe ser técnica y objetiva. 
  CRÍTICO: Los bloqueos de firewall UFW y ruidos de Tailscale son normales; no los califiques como amenaza ALTA a menos que veas ataques de fuerza bruta.
  
  Formato de salida:
  NIVEL DE AMENAZA: [Bajo/Medio/Alto]
  ENTIDADES: [Dispositivos fisicos involucrados]
  CONTENEDORES ACTIVOS: [Nombres de los contenedores/dockers detectados]
  RECOMENDACION: [Analisis tecnico breve]

  DATOS:
  \($ctx)"
}')

RESPONSE=$(curl -s -X POST http://localhost:11434/api/generate -H "Content-Type: application/json" -d "$PAYLOAD")
RESULT=$(echo "$RESPONSE" | jq -r '.response')

echo -e "\n REPORTE DE ANÁLISIS SOC DISTRIBUIDO "
echo -e "=======================================\n"

# Filtrado y estilizado final
echo "$RESULT" | sed -n '/NIVEL/,$p' | sed '/RECOMENDACION/q' \
               | sed 's/NIVEL DE AMENAZA:/ NIVEL DE AMENAZA:/g' \
               | sed 's/ENTIDADES:/ ENTIDADES INVOLUCRADAS:/g' \
               | sed 's/CONTENEDORES ACTIVOS:/ CONTENEDORES\/DOCKERS ACTIVOS:/g' \
               | sed 's/RECOMENDACION:/RECOMENDACIÓN TÉCNICA:/g'
