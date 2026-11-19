# Forense-para-server-Linux
Forense para server Linux


## Descrição do Script

O script de Resposta a Incidentes e Forense em Sistemas Linux é uma ferramenta desenvolvida para facilitar a análise forense e a investigação de incidentes em servidores Linux. Este script automatiza a coleta de diversas informações críticas do sistema, como logs de alterações em arquivos, registros de acesso e tentativas de login, configurações de rede, recursos do sistema, processos em execução, entre outros.

### Recursos Principais:
- **Menu Interativo**: Interface intuitiva com um menu numérico para navegar entre diversas funcionalidades.
- **Análise de Logs**: Filtragem e registro de logs específicos, como tentativas de login e acessos bem-sucedidos.
- **Informações do Sistema**: Coleta detalhada de informações gerais do sistema, como configurações de rede, recursos de hardware, e versões de software.
- **Monitoramento de Processos**: Exibição de processos em execução e estatísticas de desempenho.
- **Segurança e Personalização**: Opções para salvar resultados em arquivos específicos ou exibir na tela, adaptável para diversas necessidades de análise forense e segurança cibernética.

Este script é útil para administradores de sistemas, analistas de segurança e equipes de resposta a incidentes que necessitam de uma ferramenta eficiente e prática para investigar e responder a eventos de segurança em ambientes Linux.

---

## 💻 Requisitos de Sistema / System Requirements

### 🇧🇷 Português (BR) — Configuração Mínima & Recomendada

O script **Forense para Server Linux (`linux_incident_response.sh`)** foi projetado em **Bash nativo** para baixo impacto durante a triagem de incidentes em servidores em produção, operando em três perfis de hardware conforme o volume de arquivos e logs analisados:

| Recurso | 🟢 Mínimo (VPS / Servidor Linux Minimal) | 🟡 Intermediário (Servidor de Produção c/ Logs Extensos) | 🔵 Recomendado (Análise Profunda / Grandes Volumes de Arquivos) |
| :--- | :--- | :--- | :--- |
| **CPU** | **1 vCPU** (`x86_64` / `arm64`) | **2 vCPUs** (`x86_64` / `arm64`) | **4+ vCPUs** (`x86_64` / `arm64`) |
| **Memória RAM** | **256 MB a 512 MB RAM** (script consome < 15 MB) | **1 GB a 2 GB RAM** | **4 GB+ RAM** |
| **Armazenamento (SSD)** | **50 MB livres** (+ espaço proporcional aos relatórios gerados) | **500 MB a 2 GB livres** (saídas de `find /` e coleta de logs) | **5 GB+ SSD livres** (grandes dumps forenses sem impactar o SO) |
| **GPU (Opcional)** | Não necessária (execução 100% CLI/TTY) | Não necessária | Não necessária |
| **Sistema Operacional** | Ubuntu / Debian (18.04–26.04 LTS, Debian 10–12+) | Ubuntu / Debian (ou Linux c/ `systemd` e `/var/log/auth.log`) | Ubuntu 22.04 / 24.04 LTS ou Debian 12+ (execução como `root` / `sudo`) |

#### 📦 Consumo por Componente da Arquitetura
- **Motor Interativo do Script (`linux_incident_response.sh` em `Bash`)**: ~5 MB a 15 MB de RAM.
- **Varredura de Arquivos & Persistência (`find / -type f -mtime`, `find / -name '*.log'`, `crontab`, `/etc/init.d`)**: Baixo consumo de RAM (~20 MB a 80 MB), porém intensivo em I/O de disco conforme a quantidade de arquivos no servidor.
- **Coleta de Logs, Rede & Processos (`grep`/`awk` em `/var/log/auth.log*` e `/var/log/syslog*`, `journalctl`, `ps`, `top`, `htop`, `ip`/`ifconfig`, `iptables`)**: ~20 MB a 150 MB de RAM de acordo com o tamanho dos arquivos de log.

#### 🛠️ Dependências de Software
- **Shell & Permissões**: `GNU Bash 4.0+` e privilégios `root` (`sudo`) para leitura completa de `/etc/shadow`, `/etc/sudoers`, `iptables -L` e logs do sistema.
- **Utilitários Core (GNU/Linux)**: `findutils` (`find`), `coreutils` (`date`, `cat`, `tail`, `ls`, `df`, `uname`, `whoami`), `grep`, `awk`, `procps` (`ps`, `top`, `free`, `uptime`), `util-linux` (`last`), `systemd` (`systemctl`, `journalctl`), `cron` (`crontab`).
- **Utilitários de Rede & Monitoramento (opcionais por distribuição)**: `iproute2` (`ip`), `net-tools` (`ifconfig`, `netstat`, `route`), `iptables`, `iputils-ping` (`ping`), `htop`.

### 🇺🇸 English — Minimum & Recommended Configuration

**Forense para Server Linux (`linux_incident_response.sh`)** is built in **native Bash** for minimal footprint during live incident triage on Linux servers, operating across three hardware profiles depending on filesystem and log volume:

| Resource | 🟢 Minimum (Minimal VPS / Lightweight Linux Server) | 🟡 Intermediate (Production Server w/ Large Logs) | 🔵 Recommended (Deep Audit / High-Volume Filesystems) |
| :--- | :--- | :--- | :--- |
| **CPU** | **1 vCPU** (`x86_64` / `arm64`) | **2 vCPUs** (`x86_64` / `arm64`) | **4+ vCPUs** (`x86_64` / `arm64`) |
| **RAM** | **256 MB to 512 MB RAM** (script uses < 15 MB) | **1 GB to 2 GB RAM** | **4 GB+ RAM** |
| **Storage (SSD)** | **50 MB free** (+ space proportional to exported reports) | **500 MB to 2 GB free** (`find /` outputs and log collection) | **5 GB+ SSD free** (large forensic dumps without filling rootfs) |
| **GPU (Optional)** | Not required (100% CLI/TTY execution) | Not required | Not required |
| **Operating System** | Ubuntu / Debian (18.04–26.04 LTS, Debian 10–12+) | Ubuntu / Debian (or Linux w/ `systemd` & `/var/log/auth.log`) | Ubuntu 22.04 / 24.04 LTS or Debian 12+ (`root` / `sudo` execution) |

#### 📦 Resource Usage by Architecture Component
- **Interactive Script Engine (`linux_incident_response.sh` in `Bash`)**: ~5 MB to 15 MB RAM.
- **Filesystem & Persistence Scanning (`find / -type f -mtime`, `find / -name '*.log'`, `crontab`, `/etc/init.d`)**: Low RAM footprint (~20 MB to 80 MB), disk I/O bound depending on total file count.
- **Log, Network & Process Collection (`grep`/`awk` on `/var/log/auth.log*` & `/var/log/syslog*`, `journalctl`, `ps`, `top`, `htop`, `ip`/`ifconfig`, `iptables`)**: ~20 MB to 150 MB RAM depending on log archive size.

#### 🛠️ Software Dependencies
- **Shell & Privileges**: `GNU Bash 4.0+` and `root` (`sudo`) privileges to read `/etc/shadow`, `/etc/sudoers`, `iptables -L`, and protected system logs.
- **Core GNU/Linux Utilities**: `findutils` (`find`), `coreutils` (`date`, `cat`, `tail`, `ls`, `df`, `uname`, `whoami`), `grep`, `awk`, `procps` (`ps`, `top`, `free`, `uptime`), `util-linux` (`last`), `systemd` (`systemctl`, `journalctl`), `cron` (`crontab`).
- **Network & Monitoring Utilities (distro-dependent)**: `iproute2` (`ip`), `net-tools` (`ifconfig`, `netstat`, `route`), `iptables`, `iputils-ping` (`ping`), `htop`.
