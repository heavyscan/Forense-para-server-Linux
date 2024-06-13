#!/bin/bash

# Função para imprimir comandos em vermelho
print_command() {
  echo -e "\e[31m$1\e[0m"
}

# Função para registrar logs de alterações nos arquivos
log_file_changes() {
  local days=$1
  local log_file=$2
  echo "### Arquivos Modificados nos Últimos $days Dias ###" > "$log_file"
  find / -type f -mtime -"$days" -printf "%Tc %p\n" | while read -r line; do
    echo "$(date +"%F %T") - $line - Usuário: $(whoami) - IP: $(hostname -I)" >> "$log_file"
  done
}

# Função para registrar tentativas de acesso e acessos bem-sucedidos
log_access_attempts() {
  local days=$1
  local log_file=$2
  echo "### IPs que acessaram ou tentaram acessar o servidor nos Últimos $days Dias ###" > "$log_file"
  grep -v cron /var/log/auth.log* | grep -v sudo | awk '/Accepted/ { print "Acesso: ", $1, $2, $3, $11 } /Failed/ { print "Tentativa: ", $1, $2, $3, $9 }' | while read -r line; do
    echo "$(date +"%F %T") - $line - IP: $(hostname -I)" >> "$log_file"
  done
}

# Função para exibir barra de carregamento
show_progress() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  echo -n "Processando: "
  while kill -0 $pid 2>/dev/null; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
  echo "Feito!"
}

# Função para executar um comando com barra de carregamento
execute_with_progress() {
  local cmd=$1
  eval "$cmd" &
  local pid=$!
  show_progress $pid
  wait $pid
}

# Função para exibir o menu e capturar a escolha do usuário
show_menu() {
  while true; do
    clear
    echo "=========================================================================================================================="
    echo "=    ###              #####            ######            #######           ##   ##            #####            #######   = "
    echo "=   ## ##            ##   ##            ##  ##            ##   #           ###  ##           ##   ##            ##   #   = "
    echo "=    #               ##   ##            ##  ##            ## #             #### ##           #                  ## #     = "
    echo "=  ####              ##   ##            #####             ####             ## ####            #####             ####     = "
    echo "=   ##               ##   ##            ## ##             ## #             ##  ###                ##            ## #     = "
    echo "=   ##               ##   ##            ##  ##            ##   #           ##   ##           ##   ##            ##   #   = "
    echo "=  ####               #####            #### ##           #######           ##   ##            #####            #######   = "
    echo "=                                                                                                                        = "
    echo "=                                                 Forense para server Linux                                              = "
    echo "=                                                                                                                        = "
    echo "=                                                                                             criado por:                = "
    echo "=                                                                                             Luiz Eduardo E. de Souza   = "
    echo "=========================================================================================================================="
    echo ""
    echo "Selecione uma opção:"
    echo "1) Registrar alterações de arquivos"
    echo "2) Registrar tentativas de acesso e acessos"
    echo "3) Informações de Contas de Usuários"
    echo "4) Informações Gerais do Sistema"
    echo "5) Recursos do Sistema"
    echo "6) Configurações de Rede"
    echo "7) Processos"
    echo "8) Serviços"
    echo "9) Entradas de Logs"
    echo "10) Arquivos"
    echo "11) Atividades de Revisão"
    echo "12) Áreas de Persistência"
    echo "13) Sair"
    read -p "Escolha uma opção: " choice
    case $choice in
      1) filter_logs "alterações de arquivos" log_file_changes ;;
      2) filter_logs "tentativas de acesso e acessos" log_access_attempts ;;
      3) user_accounts ;;
      4) general_information ;;
      5) system_resources ;;
      6) network_settings ;;
      7) processes ;;
      8) services ;;
      9) log_entries ;;
      10) files ;;
      11) review_activities ;;
      12) persistence_areas ;;
      13) exit 0 ;;
      *) echo "Opção inválida"; sleep 1 ;;
    esac
  done
}

# Função para filtrar logs por data
filter_logs() {
  local description=$1
  local log_function=$2
  echo "Filtrar $description por:"
  echo "1) Data específica"
  echo "2) Últimos 5 dias"
  echo "3) Últimos 15 dias"
  echo "4) Últimos 30 dias"
  read -p "Escolha uma opção: " filter_choice
  case $filter_choice in
    1) 
      read -p "Informe a data (formato YYYY-MM-DD): " date
      read -p "Informe o nome do arquivo de saída: " output_file
      execute_with_progress "$log_function $((($(date +%s) - $(date -d "$date" +%s)) / 86400)) $output_file"
      ;;
    2) 
      read -p "Informe o nome do arquivo de saída: " output_file
      execute_with_progress "$log_function 5 $output_file" ;;
    3) 
      read -p "Informe o nome do arquivo de saída: " output_file
      execute_with_progress "$log_function 15 $output_file" ;;
    4) 
      read -p "Informe o nome do arquivo de saída: " output_file
      execute_with_progress "$log_function 30 $output_file" ;;
    *) 
      echo "Opção inválida"; filter_logs "$description" "$log_function" ;;
  esac
}

# Função para escolher entre salvar em arquivo ou imprimir na tela
choose_output() {
  local commands=("$@")
  echo "Escolha a opção de saída:"
  echo "1) Salvar em arquivo"
  echo "2) Imprimir na tela"
  read -p "Escolha uma opção: " output_choice
  case $output_choice in
    1)
      read -p "Informe o nome do arquivo de saída: " output_file
      for cmd in "${commands[@]}"; do
        echo "### Executando: $cmd" >> "$output_file"
        eval "$cmd" >> "$output_file" 2>&1
      done
      ;;
    2)
      for cmd in "${commands[@]}"; do
        print_command "### Executando: $cmd"
        read -p "Pressione Enter para continuar..."
        eval "$cmd"
      done
      ;;
    *)
      echo "Opção inválida"; choose_output "${commands[@]}" ;;
  esac
}

user_accounts() {
  echo "### Informações de Contas de Usuários ###"
  user_account_commands=(
    "echo \$USER # Exibe o usuário atual"
    "passwd -S \$USER # Mostra o status da senha do usuário especificado"
    "grep ':0:' /etc/passwd # Lista os usuários com ID de login igual a zero (root)"
    "cat /etc/passwd # Exibe o conteúdo do arquivo de senhas"
    "cat /etc/shadow # Exibe o conteúdo do arquivo de senhas sombreadas"
    "cat /etc/group # Exibe o conteúdo do arquivo de grupos"
    "cat /etc/sudoers # Exibe o conteúdo do arquivo de sudoers"
  )

  choose_output "${user_account_commands[@]}"
}

general_information() {
  echo "### Informações Gerais do Sistema ###"
  general_info_commands=(
    "date # Exibe a data e hora atuais"
    "cat /etc/timezone # Exibe o fuso horário do sistema"
    "uname -a # Exibe informações do sistema"
    "uname -m # Exibe a arquitetura do sistema"
    "cat /etc/*-release # Exibe informações da distribuição"
    "hostname # Exibe o nome do host"
    "cat /etc/hostname # Exibe o conteúdo do arquivo hostname"
  )

  choose_output "${general_info_commands[@]}"
}

system_resources() {
  echo "### Recursos do Sistema ###"
  system_resources_commands=(
    "uptime # Exibe o tempo de atividade do sistema"
    "free # Exibe o uso da memória"
    "df # Exibe o uso do disco"
    "cat /proc/meminfo # Exibe informações detalhadas sobre a memória"
    "cat /proc/mounts # Exibe informações sobre os pontos de montagem"
  )

  choose_output "${system_resources_commands[@]}"
}

network_settings() {
  echo "### Configurações de Rede ###"
  network_settings_commands=(
    "ifconfig # Exibe o estado da interface de rede"
    "ip addr # Exibe endereços IP das interfaces de rede"
    "netstat -nr # Exibe a tabela de roteamento do kernel"
    "route -n # Exibe a tabela de roteamento do kernel"
    "iptables -L # Exibe as regras do firewall"
    "hostname -I # Exibe o endereço IP do host"
    "ping -c 3 google.com # Testa a conectividade com a internet"
  )

  choose_output "${network_settings_commands[@]}"
}

processes() {
  echo "### Processos ###"
  processes_commands=(
    "ps aux # Lista todos os processos em execução no sistema"
    "top -n 1 -o +%CPU # Exibe os processos em execução ordenados por uso de CPU"
    "htop # Exibe uma interface interativa para gerenciar processos"
  )

  choose_output "${processes_commands[@]}"
}

services() {
  echo "### Serviços ###"
  services_commands=(
    "service --status-all | grep + # Exibe os serviços ativos"
    "systemctl list-units --type=service --state=running # Lista os serviços em execução"
    "systemctl list-unit-files --type=service # Lista todos os serviços instalados"
  )

  choose_output "${services_commands[@]}"
}

log_entries() {
  echo "### Entradas de Logs ###"
  log_entries_commands=(
    "tail -n 50 /var/log/syslog # Exibe as últimas 50 linhas do log do sistema"
    "tail -n 50 /var/log/auth.log # Exibe as últimas 50 linhas do log de autenticação"
    "journalctl -n 50 # Exibe as últimas 50 entradas do registro do sistema"
  )

  choose_output "${log_entries_commands[@]}"
}

files() {
  echo "### Arquivos ###"
  files_commands=(
    "ls -l /var/log # Lista os arquivos no diretório /var/log"
    "ls -l /etc # Lista os arquivos no diretório /etc"
    "find / -type f -name '*.log' -exec ls -lh {} + # Lista todos os arquivos .log no sistema"
  )

  choose_output "${files_commands[@]}"
}

review_activities() {
  echo "### Atividades de Revisão ###"
  review_activities_commands=(
    "last # Exibe as últimas entradas de log de login"
    "cat /var/log/syslog* | grep -i 'cron' # Exibe atividades relacionadas ao cron"
    "cat /var/log/auth.log* | grep -i 'sudo' # Exibe atividades relacionadas ao sudo"
  )

  choose_output "${review_activities_commands[@]}"
}

persistence_areas() {
  echo "### Áreas de Persistência ###"
  persistence_areas_commands=(
    "crontab -l # Lista as tarefas cron agendadas"
    "cat ~/.bashrc # Exibe o conteúdo do arquivo .bashrc do usuário"
    "cat /etc/crontab # Exibe o conteúdo do arquivo /etc/crontab"
    "ls -lh /etc/init.d # Lista os scripts de inicialização do sistema"
  )

  choose_output "${persistence_areas_commands[@]}"
}

# Iniciar o menu principal
show_menu

