#!/bin/bash
clear
# BUILD BY SANDERETHX - YOUTUBE.COM/SANDERETHX
# Refatorado para Interface Gráfica 'dialog' c/ Barra de Progresso e Caixa de Log

export LC_ALL=C.UTF-8
export DEBIAN_FRONTEND=noninteractive

if [ "$EUID" -ne 0 ]; then
    echo -e "Por favor, execute este script como root (usando sudo ou logado como root).\nPlease run this script as root (using sudo or logged as root)."
    exit 1
fi

LOG_FILE="/var/log/install-pnetlabv6-ethx.log"
> "$LOG_FILE"
rm -f /tmp/pnet_install_success

# Verifica se o Dialog está instalado (utilizado para criar as multiplas caixas simultaneas)
if ! command -v dialog > /dev/null 2>&1; then
    echo "Instalando dependencias graficas / Installing graphic dialog..."
    apt-get update -q >> "$LOG_FILE" 2>&1
    apt-get install -y dialog whiptail >> "$LOG_FILE" 2>&1
fi

LANG_OPT=$(dialog --title "PNETLab v6 Installer" --menu "Selecione o Idioma / Select Language\n\n[LOG]: $LOG_FILE" 18 65 2 \
"Portugues (Brasil)" "" \
"English" "" 3>&1 1>&2 2>&3)
MENU_EXIT=$?

if [ $MENU_EXIT -ne 0 ]; then
    # O user cancelou o menu (apertou Esc/Cancel)
    clear
    echo "Instalacao cancelada / Installation cancelled."
    exit 0
fi

if [ "$LANG_OPT" == "Portugues (Brasil)" ]; then
    MSG_TITLE="Instalador Online PNETLab v6"
    MSG_CHK_UBUNTU="[1/9] Verificando versao do Ubuntu..."
    MSG_UBUNTU_ERR_1="A instalacao foi rejeitada. Este script roda apenas no UBUNTU 20.04"
    MSG_CLEAN_DPKG="[2/9] Limpando travas do dpkg e ajustando pacotes..."
    MSG_APT_UPDATE="[3/9] Atualizando repositorios locais..."
    MSG_SSH_CFG="[4/9] Configurando regras de sistema (SSH e Root)..."
    MSG_DETECT_HYPER="[5/9] Detectando e redimensionando hypervisor..."
    MSG_RM_CONFLICTS="[6/9] Removendo pacotes conflitantes..."
    MSG_INST_DEPS="[7/9] Baixando dependencias base..."
    MSG_INST_PKGS="[8/9] Instalando Modulos PNETLab..."
    MSG_CFG_HOST="[9/9] Ajustes Finais e Servidor Web..."
    MSG_OFFLINE_ERR="Falha ao tentar baixar pacote da URL"
    MSG_DONE_1="A instalacao ocorreu com sucesso! O sistema sera reiniciado."
    MSG_DONE_2="Apos o reboot, atencao:\nO login DEVE ser realizado com a seguinte credencial para iniciar o SETUP FINAL do servidor:\n\nUsuario: root\nSenha: pnet"
    MSG_DONE_3="Clique em <OK> para REBOOTAR a maquina imediatamente."
    MSG_CRITICAL="ERRO CRITICO"
    MSG_LOG_ERR="Verifique o arquivo de log para detalhes:"
else
    MSG_TITLE="PNETLab v6 Online Installer"
    MSG_CHK_UBUNTU="[1/9] Checking Ubuntu version..."
    MSG_UBUNTU_ERR_1="Installation rejected. You must use UBUNTU 20.04"
    MSG_CLEAN_DPKG="[2/9] Cleaning dpkg locks..."
    MSG_APT_UPDATE="[3/9] Updating package lists..."
    MSG_SSH_CFG="[4/9] Configuring SSH and systemd..."
    MSG_DETECT_HYPER="[5/9] Detecting and resizing hypervisor..."
    MSG_RM_CONFLICTS="[6/9] Removing conflicting packages..."
    MSG_INST_DEPS="[7/9] Downloading base dependencies..."
    MSG_INST_PKGS="[8/9] Downloading PNETLAB Packages..."
    MSG_CFG_HOST="[9/9] Configuring hostname & Web Server..."
    MSG_OFFLINE_ERR="Failed to download package from URL"
    MSG_DONE_1="Installation completed successfully! The system will be rebooted."
    MSG_DONE_2="After reboot, attention:\nYou MUST login with the following credentials to run the FINAL SETUP of the server:\n\nUsername: root\nPassword: pnet"
    MSG_DONE_3="Click <OK> to REBOOT the machine immediately."
    MSG_CRITICAL="CRITICAL ERROR"
    MSG_LOG_ERR="Check the log file for details:"
fi

show_error() {
    local err_msg="$1"
    dialog --title "$MSG_CRITICAL" --msgbox "$err_msg\n\n$MSG_LOG_ERR $LOG_FILE" 12 70 >/dev/tty </dev/tty
    exit 1
}

run_log() {
    local exit_fail=$1
    local err_msg="$2"
    shift 2

    echo "============= EXECUTING =============" >> "$LOG_FILE"
    echo "$*" >> "$LOG_FILE"
    
    # O SED Unbuffered filtra os caracteres ANSI coloridos no tempo real, preservando o bash Status
    export DPKG_COLORS=never
    TERM=dumb "$@" 2>&1 | sed -ru "s/\x1B\[[0-9;]*[a-zA-Z]//g" >> "$LOG_FILE"
    local ret=${PIPESTATUS[0]}
    
    if [ $ret -ne 0 ] && [ "$exit_fail" -eq 1 ]; then
        show_error "$err_msg"
    fi
    return $ret
}

# Configura o script para interromper a execução inteira caso um erro fatal desabe dentro da subshell do dialog
set -o pipefail

# URLs de Repositório Cloud
KERNEL=pnetlab_kernel.zip
URL_KERNEL=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/L/linux-5.17.15-pnetlab-uksm/pnetlab_kernel.zip
URL_PRE_DOCKER=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/D/pre-docker.zip
URL_PNET_GUACAMOLE=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/P/PNET_GUACAMOLE/pnetlab-guacamole_6.0.0-7_amd64.deb
URL_PNET_DYNAMIPS=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/P/PNET_DYNAMIPS/pnetlab-dynamips_6.0.0-30_amd64.deb
URL_PNET_SCHEMA=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/P/PNET_SCHEMA/pnetlab-schema_6.0.0-30_amd64.deb
URL_PNET_VPC=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/P/PNET_VPC/pnetlab-vpcs_6.0.0-30_amd64.deb
URL_PNET_QEMU=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/P/PNET_QEMU/pnetlab-qemu_6.0.0-30_amd64.deb
URL_PNET_DOCKER=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/P/PNET_DOCKER/pnetlab-docker_6.0.0-30_amd64.deb
URL_PNET_PNETLAB=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/P/PNET_PNETLAB/pnetlab_6.0.0-103_amd64.deb
URL_PNET_WIRESHARK=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/P/PNET_WIRESHARK/pnetlab-wireshark_6.0.0-30_amd64.deb
URL_PNET_TPM=https://labhub.eu.org/0:/pnetlab/upgrades_pnetlab/focal/T/swtpm-focal.zip

# Limpa qualquer rastro do menu anterior antes de lançar o painel duplo
clear

# O Bloco PIPED começa aqui, alimentando simultaneamente a caixa de status inferior (--gauge)
{
    # Preservamos a saída padrão (pipe do dialog) no FD 4 para evitar que subshells de log interceptem a Gauge
    exec 4>&1

    update_gauge() {
        local pct=$1
        local txt=$2
        echo "XXX" >&4
        echo "$pct" >&4
        echo "$txt" >&4
        echo "XXX" >&4
    }

    # [1/9] OS Check
    update_gauge 5 "$MSG_CHK_UBUNTU"
    lsb_release -r -s | grep -q 20.04
    if [ $? -ne 0 ]; then
        show_error "$MSG_UBUNTU_ERR_1"
    fi
    
    # [2/9] DPKG
    update_gauge 10 "$MSG_CLEAN_DPKG"
    run_log 0 "" rm -f /var/lib/dpkg/lock*
    run_log 0 "" dpkg --configure -a

    azure_disk_tune() {
        ls -l /dev/disk/by-id/ | grep -q sdc && {
            ( echo o; echo n; echo p; echo 1; echo; echo; echo w ) | sudo fdisk /dev/sdc >> "$LOG_FILE" 2>&1
            run_log 0 "" mkfs.ext4 -F /dev/sdc1
            grep -q "/dev/sdc1" /etc/fstab || echo "/dev/sdc1	/opt	ext4	defaults,discard	0 0" >>/etc/fstab
            run_log 0 "" mount /opt
        }
    }
    uname -a | grep -q -- "-azure " && azure_disk_tune

    # [3/9] APT
    update_gauge 20 "$MSG_APT_UPDATE"
    run_log 1 "Apt update error" apt-get update -q

    # [4/9] SSH Config
    update_gauge 30 "$MSG_SSH_CFG"
    run_log 0 "" sed -i -e "s/.*PermitRootLogin .*/PermitRootLogin yes/" /etc/ssh/sshd_config
    run_log 0 "" sed -i -e 's/.*DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf
    run_log 0 "" systemctl restart ssh
    if [ ! -e /opt/ovf/.configured ]; then
        echo root:pnet | chpasswd >> "$LOG_FILE" 2>&1
    fi

    # [5/9] Hypervisor
    update_gauge 40 "$MSG_DETECT_HYPER"
    systemd-detect-virt -v >/tmp/hypervisor 2>/dev/null || true
    resize() {
        ROOTLV=$(mount | grep ' / ' | awk '{print $1}')
        if [ -n "$ROOTLV" ]; then
            run_log 0 "" lvextend -l +100%FREE "$ROOTLV"
            run_log 0 "" resize2fs "$ROOTLV"
        fi
    }
    fgrep -e kvm -e none /tmp/hypervisor >/dev/null 2>&1 && resize

    # [6/9] Remove Conflicting
    update_gauge 50 "$MSG_RM_CONFLICTS"
    run_log 0 "" bash -c 'apt-get purge -y docker.io containerd runc php8* -q'
    run_log 0 "" rm -f /var/lib/dpkg/lock*

    # [7/9] Install Dependencies (Massive Package List with active Progress check)
    update_gauge 60 "$MSG_INST_DEPS"
    run_log 1 "Base deps (ifupdown unzip) failed" apt-get install -y ifupdown unzip
    
    # Progresso entre 60% e 80% baseado em APT Status
    export DPKG_COLORS=never
    TERM=dumb apt-get install -y resolvconf php7.4 php7.4-yaml php7.4-common php7.4-cli php7.4-curl php7.4-gd php7.4-mbstring php7.4-mysql php7.4-sqlite3 php7.4-xml php7.4-zip libapache2-mod-php7.4 libnet-pcap-perl duc libspice-client-glib-2.0-8 libtinfo5 libncurses5 libncursesw5 php-gd ntpdate vim dos2unix apache2 bridge-utils build-essential cpulimit debconf-utils dialog dmidecode genisoimage iptables lib32gcc1 lib32z1 pastebinit php-xml libc6 libc6-i386 libelf1 libpcap0.8 libsdl1.2debian logrotate lsb-release lvm2 ntp php rsync sshpass autossh php-cli php-imagick php-mysql php-sqlite3 plymouth-label python3-pexpect sqlite3 tcpdump telnet uml-utilities zip libguestfs-tools cgroup-tools libyaml-0-2 php-curl php-mbstring net-tools php-zip python2 libapache2-mod-php mysql-server libavcodec58 libavformat58 libavutil56 libswscale5 libfreerdp-client2-2 libfreerdp-server2-2 libfreerdp-shadow-subsystem2-2 libfreerdp-shadow2-2 libfreerdp2-2 winpr-utils gir1.2-pango-1.0 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpangoxft-1.0-0 pango1.0-tools pkg-config libssh2-1 libtelnet2 libvncclient1 libvncserver1 libwebsockets15 libpulse0 libpulse-mainloop-glib0 libssl1.1 libvorbis0a libvorbisenc2 libvorbisfile3 libwebp6 libwebpmux3 libwebpdemux2 libcairo2 libcairo-gobject2 libcairo-script-interpreter2 libjpeg62 libpng16-16 libtool libuuid1 libossp-uuid16 default-jdk default-jdk-headless tomcat9 tomcat9-admin tomcat9-docs libaio1 libasound2 libbrlapi0.7 libcacard0 libepoxy0 libfdt1 libgbm1 libgcc-s1 libglib2.0-0 libgnutls30 libibverbs1 libjpeg8 libncursesw6 libnettle7 libnuma1 libpixman-1-0 libpmem1 librdmacm1 libsasl2-2 libseccomp2 libslirp0 libspice-server1 libtinfo6 libusb-1.0-0 libusbredirparser1 libvirglrenderer1 zlib1g qemu-system-common libxenmisc4.11 libcapstone3 libvdeplug2 libnfs13 udhcpd libxss1 libxencall1 libxendevicemodel1 libxenevtchn1 libxenforeignmemory1 libxengnttab1 libxenstore3.0 libxentoollog1 libxentoolcore1 -o APT::Status-Fd=3 3> >(
        while read -r line; do
            if [[ "$line" == pmstatus:* ]]; then
                pct=$(echo "$line" | cut -d: -f3 | cut -d. -f1)
                global_pct=$(( 60 + (pct * 20 / 100) ))
                if [ "$global_pct" -gt 80 ]; then global_pct=80; fi
                update_gauge "$global_pct" "$MSG_INST_DEPS ($pct%)"
            fi
        done
    ) 2>&1 | sed -ru "s/\x1B\[[0-9;]*[a-zA-Z]//g" >> "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        show_error "Apt installation error. Use o arquivo install_pnetlab_v6.log"
    fi

    check_php=$(run_log 0 "" update-alternatives --set php /usr/bin/php7.4)

    # [8/9] PNET PACKAGES ONLINE DOWNLOAD
    update_gauge 81 "$MSG_INST_PKGS (Kernel)"
    
    BUILD_DIR="/tmp/pnet_install"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || show_error "Diretorio invalido"

    download_url_progress() {
        local TARGET_URL=$1
        local EXTRACTION_DIR=$2
        local DEB_NAME=$3
        
        # Tirando o parâmetro -q do wget e colocando progress=dot:mega para renderizar liso dentro da caixa de LOG
        run_log 0 "Wget $TARGET_URL" wget --content-disposition --progress=dot:mega "$TARGET_URL"
        if [ $? -eq 0 ]; then
            if [ -n "$EXTRACTION_DIR" ]; then
                 run_log 1 "" unzip -o "$EXTRACTION_DIR.zip"
                 run_log 1 "" bash -c "dpkg -i $EXTRACTION_DIR/*.deb"
            else
                 run_log 1 "" bash -c "dpkg -i $DEB_NAME"
            fi
        else
            show_error "$MSG_OFFLINE_ERR\nURL: $TARGET_URL"
        fi
    }

    if ! dpkg-query -l | grep linux-image-5.17.15-pnetlab-uksm-2 | grep -q 5.17.15-pnetlab-uksm-2-1; then
        download_url_progress "$URL_KERNEL" "pnetlab_kernel" ""
    fi
    
    update_gauge 82 "$MSG_INST_PKGS (Docker)"
    if ! dpkg-query -l | grep -q docker-ce; then
        download_url_progress "$URL_PRE_DOCKER" "pre-docker" ""
    fi
    
    update_gauge 83 "$MSG_INST_PKGS (SWTPM)"
    if ! dpkg-query -l | grep -q swtpm; then
        download_url_progress "$URL_PNET_TPM" "swtpm-focal" ""
    fi

    update_gauge 84 "$MSG_INST_PKGS (PNET-Docker)"
    if ! dpkg-query -l | grep pnetlab-docker | grep -q 6.0.0-30; then
        download_url_progress "$URL_PNET_DOCKER" "" "pnetlab-docker_*.deb"
    fi

    update_gauge 85 "$MSG_INST_PKGS (Schema)"
    if ! dpkg-query -l | grep pnetlab-schema | grep -q 6.0.0-30; then
        download_url_progress "$URL_PNET_SCHEMA" "" "pnetlab-schema_*.deb"
    fi

    update_gauge 86 "$MSG_INST_PKGS (Guacamole)"
    if ! dpkg-query -l | grep pnetlab-guacamole | grep -q 6.0.0-7; then
        download_url_progress "$URL_PNET_GUACAMOLE" "" "pnetlab-guacamole_*.deb"
    fi

    update_gauge 87 "$MSG_INST_PKGS (VPCS)"
    if ! dpkg-query -l | grep pnetlab-vpcs | grep -q 6.0.0-30; then
        download_url_progress "$URL_PNET_VPC" "" "pnetlab-vpcs_*.deb"
    fi

    update_gauge 88 "$MSG_INST_PKGS (Dynamips)"
    if ! dpkg-query -l | grep pnetlab-dynamips | grep -q 6.0.0-30; then
        download_url_progress "$URL_PNET_DYNAMIPS" "" "pnetlab-dynamips_*.deb"
    fi

    update_gauge 89 "$MSG_INST_PKGS (Wireshark)"
    if ! dpkg-query -l | grep pnetlab-wireshark | grep -q 6.0.0-30; then
        download_url_progress "$URL_PNET_WIRESHARK" "" "pnetlab-wireshark_*.deb"
    fi

    update_gauge 90 "$MSG_INST_PKGS (QEMU)"
    if ! dpkg-query -l | grep pnetlab-qemu | grep -q 6.0.0-30; then
        download_url_progress "$URL_PNET_QEMU" "" "pnetlab-qemu_*.deb"
    fi

    # [9/9] Install PNETLab / Hosts setup
    update_gauge 94 "$MSG_CFG_HOST"
    fgrep "127.0.1.1 pnetlab.example.com pnetlab" /etc/hosts || echo 127.0.2.1 pnetlab.example.com pnetlab >>/etc/hosts 2>/dev/null
    echo pnetlab >/etc/hostname 2>/dev/null

    download_url_progress "$URL_PNET_PNETLAB" "" "pnetlab_6*.deb"

    # Cloud tunning
    gcp_tune() {
        cd /sys/class/net/ || return 1
        for i in ens*; do echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="'$(cat $i/address)'", ATTR{type}=="1", KERNEL=="ens*", NAME="'$i'"'; done >/etc/udev/rules.d/70-persistent-net.rules
        run_log 0 "" sed -i -e 's/NAME="ens4"/NAME="eth0"/' /etc/udev/rules.d/70-persistent-net.rules
        run_log 0 "" sed -i -e 's/ens4/eth0/' /etc/netplan/50-cloud-init.yaml
        run_log 0 "" sed -i -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        run_log 0 "" apt-mark hold linux-image-gcp
        run_log 0 "" mv /boot/vmlinuz-*gcp /root
        run_log 0 "" update-grub2
    }

    azure_kernel_tune() {
        run_log 0 "" apt udpate -q
        echo "options kvm_intel nested=1 vmentry_l1d_flush=never" >/etc/modprobe.d/qemu-system-x86.conf
        run_log 0 "" sed -i -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    }

    update_gauge 95 "$MSG_CFG_HOST (Cloud Tuning)"
    dmidecode -t bios | grep -q Google && gcp_tune
    uname -a | grep -q -- "-azure " && azure_kernel_tune

    update_gauge 99 "System Cleanup..."
    run_log 0 "" apt-get autoremove -y -q
    run_log 0 "" apt-get autoclean -y -q
    run_log 0 "" rm -rf "$BUILD_DIR"

    update_gauge 100 "Concluído!"
    # Aguarda o log sincronizar
    sleep 1
    touch /tmp/pnet_install_success

} | (
    LINES=$(tput lines 2>/dev/null || echo 24)
    COLS=$(tput cols 2>/dev/null || echo 80)
    
    if [ "$LINES" -lt 22 ]; then LINES=22; fi
    if [ "$COLS" -lt 80 ]; then COLS=80; fi
    
    # 90% da largura nativa e 40% da altura para a caixa de LOG. Escala para telas grandes majestosamente.
    W=$(( COLS * 90 / 100 ))
    if [ "$W" -lt 74 ]; then W=74; fi
    
    H1=$(( LINES * 40 / 100 ))
    if [ "$H1" -lt 10 ]; then H1=10; fi
    H2=8
    
    TOTAL_H=$(( H1 + H2 + 1 ))
    SY=$(( (LINES - TOTAL_H) / 2 ))
    if [ "$SY" -lt 0 ]; then SY=0; fi
    SX=$(( (COLS - W) / 2 ))
    GY=$(( SY + H1 + 1 ))

    dialog --backtitle "Instalacao do PNETLab v6 - by Sander Ethx -> youtube.com/sanderethx" \
           --begin $SY $SX --title " Log de Execucao Real-Time " --tailboxbg "$LOG_FILE" $H1 $W \
           --and-widget \
           --begin $GY $SX --title " Status da Instalacao " --gauge "Iniciando...\nStarting up..." $H2 $W 0
)

# Conclui apenas se a flag de finalização não foi interrompida
if [ -f /tmp/pnet_install_success ]; then
    rm -f /tmp/pnet_install_success
    clear
    dialog --title "$MSG_TITLE" --msgbox "$MSG_DONE_1\n\n$MSG_DONE_2\n\n--------------------------------------------------------------\n$MSG_DONE_3" 0 0 >/dev/tty </dev/tty
    clear
    reboot
    exit 0
fi
clear
