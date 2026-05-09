# Nightmare Shield
**Hybrid Distributed Infrastructure & NOC/SOC Lab**
*Proyecto desarrollado para el AMD Developer Hackathon 2026.*

## Visión General
Nightmare Shield es una prueba de concepto operativa de una infraestructura distribuida, híbrida y descentralizada. El proyecto orquesta hardware heterogéneo a través de una red VPN (Virtual Private Network) y despliega un NOC/SOC (Network/Security Operations Center) integral. Combina monitoreo en tiempo real con **Sentinel Shield**, un agente SOC automatizado que utiliza Inteligencia Artificial generativa ejecutada localmente en hardware AMD para la auditoría y análisis de amenazas.

## Arquitectura de Hardware e Infraestructura Híbrida
El clúster está compuesto por 5 nodos físicos distribuidos, cada uno cumpliendo un rol específico dentro del ecosistema:

*   ** Nodo Maestro (Inferencia, NOC y Orquestación): Asus TUF Gaming A16**
    *   **Hardware:** AMD Ryzen 7 260 (GPU Nvidia RTX 5050 desactivada deliberadamente para demostrar la inferencia de IA 100% nativa sobre la arquitectura HawkPoint).
    *   **OS:** CachyOS.
    *   **Rol:** Ejecuta el motor de IA local (Ollama/Phi-3), el script maestro del SOC, y centraliza los dashboards de telemetría.
*   ** Nodo Hipervisor: (Legacy) HP Compaq 6000 Pro**
*   *   **Hardware:** Procesador Intel (Arquitectura Heredada)
    *   **OS:** Proxmox VE.
    *   **Rol:** Virtualización de servicios críticos mediante contenedores LXC (PCT), alojando instancias privadas como **SearXNG**.
*   ** Nodo Edge Computing: Lenovo IdeaPad**
    *   **Hardware:** AMD Ryzen 7 3700U.
    *   **OS:** CachyOS.
    *   **Rol:** Despliegue de microservicios mediante Docker (ej. Technitium DNS).
*   ** Nodo de Seguridad Perimetral: HP Pavilion g7**
*   *   **Hardware:** AMD A4-3305M
    *   **OS:** Void Linux.
    *   **Rol:** Gestión de activos en contenedores LXC nativos, alojando **Snipe-IT**.
*   ** Nodo Ligero de Gestión: (Edge Legacy) Gateway LT Series**
    *   **Hardware:** Procesador Intel (Arquitectura Heredada)
    *   **OS:** Alpine OS.
    *   **Rol:** Puente de gestión ágil mediante Wireguard.

## NOC: Network Operations Center
Para garantizar la visibilidad de la infraestructura distribuida, Nightmare Shield implementa un stack de monitoreo operativo sobre la red privada:
*   **Netdata:** Recopilación de métricas de rendimiento (CPU, RAM, red, I/O) en tiempo real en todos los nodos físicos y contenedores.
*   **Grafana:** Centralización y visualización de la telemetría recolectada por Netdata.
*   **SearXNG:** Despliegue de un motor de metabúsqueda privado y autoalojado en el hipervisor Proxmox, garantizando consultas seguras para los operadores del SOC.
*   **VPN Distribuida (Tailscale):** Infraestructura de red segura punto a punto para acceder a los dashboards y servicios internos.

##  Sentinel Shield: AI SOC Agent Local
Para garantizar la privacidad de los logs de seguridad, Nightmare Shield integra un agente SOC basado en Bash que opera de manera asíncrona:

1.  **Telemetría P2P:** Realiza consultas seguras vía SSH (`BatchMode`) a través de la red Tailscale/Wireguard, recolectando el estado en vivo de los demonios de Docker y LXC en los nodos remotos.
2.  **Inferencia Acelerada por AMD:** Todo el contexto de la infraestructura (estado de nodos, contenedores activos, logs locales y registros de UFW) se procesa localmente aprovechando la potencia del procesador **AMD Ryzen 7 260**.
3.  **Análisis Deterministico:** El modelo Phi-3 evalúa el nivel de amenaza y emite un diagnóstico técnico estructurado, evaluando el tráfico cifrado de la VPN interna frente a posibles vectores de ataque.

##  Stack Tecnológico
*   **Inteligencia Artificial:** Ollama, Phi-3.
*   **NOC & Monitoreo:** Netdata, Grafana.
*   **Privacidad & Servicios:** SearXNG, Snipe-IT.
*   **Virtualización y Orquestación:** Proxmox VE, Docker, LXC.
*   **Redes, Seguridad y Automatización:** Tailscale, Wireguard, UFW, SSH Key-Based Auth, Ansible.
*   **Sistemas Operativos:** CachyOS, Alpine Linux, Void Linux.

##  Demostración del Agente SOC en Acción
<img width="908" height="1158" alt="image" src="https://github.com/user-attachments/assets/b82976d7-2662-4ba4-903f-b9ad81a64d48" />


##  Conclusión
Nightmare Shield Demuestra como la integracion de hardwarew de distintas generaciones puede ser llevado de vuelta a la vida y ser usado de forma segura bajo una arquitectura de vpn distribuida. Al combinar un NOC tradicional con analitica centralizada de un nodo potenciado por AMD HawkPoint, se logra una infraestructura resiliente, completamente privada y altamente capaz de realizar auditorias en el *edge*. 
