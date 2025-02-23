#!/usr/bin/env bash


#Configurando as cores para ter um pouco de estilo.
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

# Tratamento de exceções
set -euo pipefail

main() {
    clear
    echo -e "${YELLOW}=== Informação do Sistema ===${RESET}"
    echo "Host: $(hostname)"
    echo "Tempo de serviço: $(uptime | awk -F'( |,|:)+' '{print $6,$7",",$8,"hours"}')"
    echo "Usuários logados: $(who | wc -l)"
    echo -e "Data: $(date)\n"

    echo -e "${YELLOW}=== Utilização de Recursos ===${RESET}"
    echo "CPU $(top -bn1 | grep load | awk '{printf "%.2f%%\n", $(NF-2)}')"
    echo "RAM: $(free -h | awk '/Mem/{printf "Used: %s/%s (%.2f%%)\n", $3,$2,$3/$2*100}')"
    echo "Disco:"
    df -h --output=source,target,pcent,avail | grep -vE 'tmpfs|udev' | awk 'NR>1 {printf "%-25s %-20s %-10s %-10s\n", $1, $2, $3, $4}'

    echo -e "\n${YELLOW}=== Monitoramento de Processos ===${RESET}"
    echo "Processos que mais usam CPU:"
    ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 6
    echo -e "\nProcessos que mais usam RAM:"
    ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head -n 6


    echo -e "\n${YELLOW}=== Checagem de segurança ===${RESET}"
    echo "Tentativas de Login com falhas:"
    if [ -f /var/log/auth.log ]; then
        grep "Erro de autenticação" /var/log/auth.log | tail -n 5
    elif [ -f /var/log/secure ]; then
        grep "Erro de autenticação" /var/log/secure | tail -n 5
    fi

    echo -e "\n${YELLOW}=== Informação de Rede ===${RESET}"
    echo "Portas Abertas:"
    ss -tulpn | awk 'NR>1 {printf "%-10s %-20s %-10s\n", $1, $5, $7}'


    echo -e "\n${YELLOW}=== Status dos Serviços ===${RESET}"
    check_services=("sshd" "nginx" "mysql")
    for service in "${check_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo -e "${GREEN}✓ $service ativo${RESET}"
        else
            echo -e "${RED}✗ $service inativo${RESET}"
        fi
    done

    echo -e "\n${YELLOW}=== Checagem de Backup ===${RESET}"
    backup_dirs=("/backup" "/var/backup")
    for dir in "${backup_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo "Diretório de Backup $dir:"
            find "$dir" -type f -mtime -7 -exec ls -lh {} \; | wc -l | xargs echo "Files modified in last 7 days:"
        fi
    done

    # Caso queira rotacionar os logs.
    # echo -e "\nRotating logs..."
    # logrotate /etc/logrotate.conf
    echo -e "\n${BLUE}=== Script completed at $(date) ===${RESET}"
}
main