#!/bin/bash
clear
# BUILD BY SANDERETHX - YOUTUBE.COM/SANDERETHX

# -----------------------------------------------------------------------
# Language Setup / Configuração de Idioma
# -----------------------------------------------------------------------
echo "================================================"
echo " Select Language / Selecione o Idioma"
echo " 1) English"
echo " 2) Português (BR)"
echo "================================================"
read -p " Option (1 or 2) [Default: 1]: " LANG_OPT
if [ "$LANG_OPT" == "2" ]; then
    MSG_OK="[OK]"
    MSG_FAILED="[FALHA]"
    MSG_ROOT_ERR="Por favor, execute este script como root (usando sudo ou logado como root)."
    MSG_TITLE="Instalador Online PNETLab v6 - Ubuntu 20.04"
    MSG_CHK_UBUNTU="[1/9] Verificando versão do Ubuntu..."
    MSG_UBUNTU_ERR_1="A instalacao foi rejeitada. Este script roda apenas no UBUNTU 20.04"
    MSG_UBUNTU_OK="Ubuntu 20.04 confirmado!"
    MSG_CLEAN_DPKG="[2/9] Limpando travas do dpkg e ajustando pacotes..."
    MSG_AZURE_DISK="Azure detectado: configurando disco de dados..."
    MSG_CHK_AZURE_DISK="Configuração de disco do Azure"
    MSG_APT_UPDATE="[3/9] Atualizando repositorios locais..."
    MSG_SSH_CFG="[4/9] Configurando regras de sistema (SSH e Root)..."
    MSG_DETECT_HYPER="[5/9] Detectando e redimensionando hypervisor..."
    MSG_DETECTED="Detectado:"
    MSG_ROOT_LV="LV Raiz:"
    MSG_RESIZE_FS="Redimensionando ROOT FS..."
    MSG_RM_CONFLICTS="[6/9] Removendo pacotes conflitantes..."
    MSG_INST_DEPS="[7/9] Baixando dependências base do PNETLab..."
    MSG_WAIT_MINUTES="Essa etapa baixa muitos repositórios. Aguarde..."
    MSG_SET_PHP="Configurado o PHP padrao."
    MSG_OFFLINE_ERR="Falha ao baixar URL ou instalar:"
    MSG_INST_PKGS="[8/9] Instalando Módulos PNETLab da nuvem..."
    MSG_ALREADY_INST="Já instalado, pulando"
    MSG_DOWNLOADING="Baixando:"
    MSG_CFG_HOST="[9/9] Hostname e Núcleo do PNETLab..."
    MSG_GCP_NET="GCP detectado: aplicando ajustes de rede..."
    MSG_AZURE_KERNEL="Azure detectado: aplicando ajustes de kernel..."
    MSG_CLEANUP="Limpando excessos de instalação..."
    MSG_DONE_1="Atualização/Instalação concluida com sucesso!"
    MSG_DONE_2="Credenciais padrão: usuario=root | senha=pnet"
    MSG_DONE_3="!! Certifique-se de REINICIAR o servidor antes de entrar !!"
    MSG_CHK_DPKG_CONF="Pacotes base reparados"
    MSG_CHK_BASE_INST="Dependências Base Instaladas"
    MSG_CHK_KERNEL="Kernel OK"
    MSG_CHK_PKG="Pacote OK:"
else
    MSG_OK="[OK]"
    MSG_FAILED="[FAILED]"
    MSG_ROOT_ERR="Please run this script as root (using sudo or logged as root)."
    MSG_TITLE="PNETLab v6 Online Installer - Ubuntu 20.04"
    MSG_CHK_UBUNTU="[1/9] Checking Ubuntu version..."
    MSG_UBUNTU_ERR_1="Upgrade has been rejected. You need to have UBUNTU 20.04 to use this script."
    MSG_UBUNTU_OK="Ubuntu 20.04 confirmed!"
    MSG_CLEAN_DPKG="[2/9] Cleaning dpkg locks..."
    MSG_AZURE_DISK="Azure detected: configuring data disk..."
    MSG_CHK_AZURE_DISK="Azure disk configuration"
    MSG_APT_UPDATE="[3/9] Updating package lists..."
    MSG_SSH_CFG="[4/9] Configuring SSH and systemd..."
    MSG_DETECT_HYPER="[5/9] Detecting hypervisor..."
    MSG_DETECTED="Detected:"
    MSG_ROOT_LV="Root LV:"
    MSG_RESIZE_FS="Resizing ROOT FS..."
    MSG_RM_CONFLICTS="[6/9] Removing conflicting packages..."
    MSG_INST_DEPS="[7/9] Downloading base dependencies..."
    MSG_WAIT_MINUTES="This step downloads many packages, please wait..."
    MSG_SET_PHP="Default PHP configured."
    MSG_OFFLINE_ERR="Failed to download or install URL:"
    MSG_INST_PKGS="[8/9] Downloading PNETLAB Packages..."
    MSG_ALREADY_INST="Already installed, skipping"
    MSG_DOWNLOADING="Downloading:"
    MSG_CFG_HOST="[9/9] Configuring hostname & PNETLab Core..."
    MSG_GCP_NET="GCP detected: applying network tuning..."
    MSG_AZURE_KERNEL="Azure detected: applying kernel tuning..."
    MSG_CLEANUP="Cleaning up unused packages..."
    MSG_DONE_1="Upgrade has been done successfully!"
    MSG_DONE_2="Default credentials: username=root password=pnet"
    MSG_DONE_3="!! Make sure to REBOOT if you install pnetlab first time !!"
    MSG_CHK_DPKG_CONF="Base packages repaired"
    MSG_CHK_BASE_INST="Base Dependencies Installed"
    MSG_CHK_KERNEL="Kernel OK"
    MSG_CHK_PKG="Package OK:"
fi

export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

# CONSTANTS
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
NO_COLOR='\033[0m'

# -----------------------------------------------------------------------
# Basic Checks
# -----------------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}${MSG_ROOT_ERR}${NO_COLOR}"
    exit 1
fi

check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}    ${MSG_OK} $1${NO_COLOR}"
    else
        echo -e "${RED}    ${MSG_FAILED} $1${NO_COLOR}"
    fi
}

echo -e "${GREEN}================================================${NO_COLOR}"
echo -e "${GREEN}   ${MSG_TITLE}         ${NO_COLOR}"
echo -e "${GREEN}================================================${NO_COLOR}"

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

# [1/9] OS Check
echo -e "\n${YELLOW}${MSG_CHK_UBUNTU}${NO_COLOR}"
lsb_release -r -s | grep -q 20.04
if [ $? -ne 0 ]; then
    echo -e "${RED}${MSG_UBUNTU_ERR_1}${NO_COLOR}"
    exit 0
fi
check "${MSG_UBUNTU_OK}"

# [2/9] DPKG
echo -e "\n${YELLOW}${MSG_CLEAN_DPKG}${NO_COLOR}"
rm /var/lib/dpkg/lock* &>/dev/null
dpkg --configure -a &>/dev/null
check "${MSG_CHK_DPKG_CONF}"

azure_disk_tune() {
    echo -e "${YELLOW}    ${MSG_AZURE_DISK}${NO_COLOR}"
    ls -l /dev/disk/by-id/ | grep -q sdc && (
        echo o; echo n; echo p; echo 1; echo; echo; echo w
    ) | sudo fdisk /dev/sdc && (
        mkfs.ext4 -F /dev/sdc1
        echo "/dev/sdc1	/opt	ext4	defaults,discard	0 0" >>/etc/fstab
        mount /opt
    )
    check "${MSG_CHK_AZURE_DISK}"
}
uname -a | grep -q -- "-azure " && azure_disk_tune

# [3/9] APT
echo -e "\n${YELLOW}${MSG_APT_UPDATE}${NO_COLOR}"
apt-get update -q

# [4/9] SSH Config
echo -e "\n${YELLOW}${MSG_SSH_CFG}${NO_COLOR}"
sed -i -e "s/.*PermitRootLogin .*/PermitRootLogin yes/" /etc/ssh/sshd_config &>/dev/null
sed -i -e 's/.*DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf &>/dev/null
systemctl restart ssh &>/dev/null
if [ ! -e /opt/ovf/.configured ]; then
    echo root:pnet | chpasswd &>/dev/null
fi

# [5/9] Hypervisor
echo -e "\n${YELLOW}${MSG_DETECT_HYPER}${NO_COLOR}"
systemd-detect-virt -v >/tmp/hypervisor
resize() {
    ROOTLV=$(mount | grep ' / ' | awk '{print $1}')
    echo -e "${GREEN}    ${MSG_ROOT_LV} ${ROOTLV}${NO_COLOR}"
    lvextend -l +100%FREE "$ROOTLV" &>/dev/null
    echo -e "${GREEN}    ${MSG_RESIZE_FS}${NO_COLOR}"
    resize2fs "$ROOTLV" &>/dev/null
}
fgrep -e kvm -e none /tmp/hypervisor 2>&1 >/dev/null
if [[ $? -eq 0 ]]; then
    grep -q kvm /tmp/hypervisor && resize &>/dev/null
    grep -q none /tmp/hypervisor && resize &>/dev/null
fi

# [6/9] Remove Conflicting
echo -e "\n${YELLOW}${MSG_RM_CONFLICTS}${NO_COLOR}"
apt-get purge -y docker.io containerd runc php8* -q &>/dev/null
rm /var/lib/dpkg/lock* &>/dev/null

# [7/9] Install Dependencies
echo -e "\n${YELLOW}${MSG_INST_DEPS}${NO_COLOR}"
echo -e "${YELLOW}    ${MSG_WAIT_MINUTES}${NO_COLOR}"
apt-get install -y ifupdown unzip &>/dev/null

# (Note: Using default Ubuntu PHP instead of ondrej/php, as PPA can hang offline/firewalled installs)
sudo apt install -y resolvconf php7.4 php7.4-yaml php7.4-common php7.4-cli php7.4-curl php7.4-gd php7.4-mbstring php7.4-mysql php7.4-sqlite3 php7.4-xml php7.4-zip libapache2-mod-php7.4 libnet-pcap-perl duc libspice-client-glib-2.0-8 libtinfo5 libncurses5 libncursesw5 php-gd ntpdate vim dos2unix apache2 bridge-utils build-essential cpulimit debconf-utils dialog dmidecode genisoimage iptables lib32gcc1 lib32z1 pastebinit php-xml libc6 libc6-i386 libelf1 libpcap0.8 libsdl1.2debian logrotate lsb-release lvm2 ntp php rsync sshpass autossh php-cli php-imagick php-mysql php-sqlite3 plymouth-label python3-pexpect sqlite3 tcpdump telnet uml-utilities zip libguestfs-tools cgroup-tools libyaml-0-2 php-curl php-mbstring net-tools php-zip python2 libapache2-mod-php mysql-server libavcodec58 libavformat58 libavutil56 libswscale5 libfreerdp-client2-2 libfreerdp-server2-2 libfreerdp-shadow-subsystem2-2 libfreerdp-shadow2-2 libfreerdp2-2 winpr-utils gir1.2-pango-1.0 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpangoxft-1.0-0 pango1.0-tools pkg-config libssh2-1 libtelnet2 libvncclient1 libvncserver1 libwebsockets15 libpulse0 libpulse-mainloop-glib0 libssl1.1 libvorbis0a libvorbisenc2 libvorbisfile3 libwebp6 libwebpmux3 libwebpdemux2 libcairo2 libcairo-gobject2 libcairo-script-interpreter2 libjpeg62 libpng16-16 libtool libuuid1 libossp-uuid16 default-jdk default-jdk-headless tomcat9 tomcat9-admin tomcat9-docs libaio1 libasound2 libbrlapi0.7 libcacard0 libepoxy0 libfdt1 libgbm1 libgcc-s1 libglib2.0-0 libgnutls30 libibverbs1 libjpeg8 libncursesw6 libnettle7 libnuma1 libpixman-1-0 libpmem1 librdmacm1 libsasl2-2 libseccomp2 libslirp0 libspice-server1 libtinfo6 libusb-1.0-0 libusbredirparser1 libvirglrenderer1 zlib1g qemu-system-common libxenmisc4.11 libcapstone3 libvdeplug2 libnfs13 udhcpd libxss1 libxencall1 libxendevicemodel1 libxenevtchn1 libxenforeignmemory1 libxengnttab1 libxenstore3.0 libxentoollog1 libxentoolcore1 &>/dev/null
check "${MSG_CHK_BASE_INST}"

update-alternatives --set php /usr/bin/php7.4 &>/dev/null

# [8/9] PNET PACKAGES ONLINE DOWNLOAD
echo -e "\n${YELLOW}${MSG_INST_PKGS}${NO_COLOR}"

# Segregated safe build folder
BUILD_DIR="/tmp/pnet_install"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

# PNETLAB CUSTOM DOWNLOADING FUNCTION WITH CHECKS
download_url() {
    local TARGET_URL=$1
    local EXTRACTION_DIR=$2
    local DEB_NAME=$3
    
    wget --content-disposition -q --show-progress "$TARGET_URL"
    if [ $? -eq 0 ]; then
        if [ ! -z "$EXTRACTION_DIR" ]; then
            # If it's a zip to extract
             unzip -o "$EXTRACTION_DIR.zip" &>/dev/null
             dpkg -i $EXTRACTION_DIR/*.deb &>/dev/null
        else
            dpkg -i $DEB_NAME &>/dev/null
        fi
        check "${MSG_CHK_PKG} $EXTRACTION_DIR$DEB_NAME"
    else
        echo -e "${RED}    [ERROR] ${MSG_OFFLINE_ERR} ($TARGET_URL)${NO_COLOR}"
    fi
}

echo -e "${GREEN}    -> Kernel...${NO_COLOR}"
dpkg-query -l | grep linux-image-5.17.15-pnetlab-uksm-2 | grep 5.17.15-pnetlab-uksm-2-1 -q
if [ $? -ne 0 ]; then
    download_url "$URL_KERNEL" "pnetlab_kernel" ""
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

echo -e "${GREEN}    -> Docker...${NO_COLOR}"
dpkg-query -l | grep docker-ce -q
if [ $? -ne 0 ]; then
    download_url "$URL_PRE_DOCKER" "pre-docker" ""
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

echo -e "${GREEN}    -> SWTPM...${NO_COLOR}"
dpkg-query -l | grep swtpm -q
if [ $? -ne 0 ]; then
    download_url "$URL_PNET_TPM" "swtpm-focal" ""
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

echo -e "${GREEN}    -> PNET-Docker...${NO_COLOR}"
dpkg-query -l | grep pnetlab-docker | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    download_url "$URL_PNET_DOCKER" "" "pnetlab-docker_*.deb"
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

echo -e "${GREEN}    -> Schema...${NO_COLOR}"
dpkg-query -l | grep pnetlab-schema | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    download_url "$URL_PNET_SCHEMA" "" "pnetlab-schema_*.deb"
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

echo -e "${GREEN}    -> Guacamole...${NO_COLOR}"
dpkg-query -l | grep pnetlab-guacamole | grep 6.0.0-7 -q
if [ $? -ne 0 ]; then
    download_url "$URL_PNET_GUACAMOLE" "" "pnetlab-guacamole_*.deb"
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

echo -e "${GREEN}    -> VPCS...${NO_COLOR}"
dpkg-query -l | grep pnetlab-vpcs | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    download_url "$URL_PNET_VPC" "" "pnetlab-vpcs_*.deb"
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

echo -e "${GREEN}    -> Dynamips...${NO_COLOR}"
dpkg-query -l | grep pnetlab-dynamips | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    download_url "$URL_PNET_DYNAMIPS" "" "pnetlab-dynamips_*.deb"
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

echo -e "${GREEN}    -> Wireshark...${NO_COLOR}"
dpkg-query -l | grep pnetlab-wireshark | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    download_url "$URL_PNET_WIRESHARK" "" "pnetlab-wireshark_*.deb"
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

echo -e "${GREEN}    -> QEMU...${NO_COLOR}"
dpkg-query -l | grep pnetlab-qemu | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    download_url "$URL_PNET_QEMU" "" "pnetlab-qemu_*.deb"
else
    echo -e "${GREEN}       ${MSG_ALREADY_INST}${NO_COLOR}"
fi

# [9/9] Install PNETLab / Hosts setup
echo -e "\n${YELLOW}${MSG_CFG_HOST}${NO_COLOR}"
fgrep "127.0.1.1 pnetlab.example.com pnetlab" /etc/hosts || echo 127.0.2.1 pnetlab.example.com pnetlab >>/etc/hosts 2>/dev/null
echo pnetlab >/etc/hostname 2>/dev/null

echo -e "${GREEN}    -> PNETLab Main Core${NO_COLOR}"
download_url "$URL_PNET_PNETLAB" "" "pnetlab_6*.deb"

# Cloud tunning
gcp_tune() {
    echo -e "${YELLOW}    ${MSG_GCP_NET}${NO_COLOR}"
    cd /sys/class/net/ || return 1
    for i in ens*; do echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="'$(cat $i/address)'", ATTR{type}=="1", KERNEL=="ens*", NAME="'$i'"'; done >/etc/udev/rules.d/70-persistent-net.rules
    sed -i -e 's/NAME="ens4"/NAME="eth0"/' /etc/udev/rules.d/70-persistent-net.rules
    sed -i -e 's/ens4/eth0/' /etc/netplan/50-cloud-init.yaml
    sed -i -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    apt-mark hold linux-image-gcp &>/dev/null
    mv /boot/vmlinuz-*gcp /root &>/dev/null
    update-grub2 &>/dev/null
}

azure_kernel_tune() {
    echo -e "${YELLOW}    ${MSG_AZURE_KERNEL}${NO_COLOR}"
    apt update &>/dev/null
    echo "options kvm_intel nested=1 vmentry_l1d_flush=never" >/etc/modprobe.d/qemu-system-x86.conf
    sed -i -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
}

dmidecode -t bios | grep -q Google && gcp_tune
uname -a | grep -q -- "-azure " && azure_kernel_tune

# Clean
echo -e "\n${YELLOW}${MSG_CLEANUP}${NO_COLOR}"
apt autoremove -y -q &>/dev/null
apt autoclean -y -q &>/dev/null

# Clean build directory
rm -rf "$BUILD_DIR" &>/dev/null

echo -e "\n${GREEN}================================================${NO_COLOR}"
echo -e "${GREEN}   ${MSG_DONE_1}         ${NO_COLOR}"
echo -e "${GREEN}   ${MSG_DONE_2}         ${NO_COLOR}"
echo -e "${GREEN}   ${MSG_DONE_3}         ${NO_COLOR}"
echo -e "${GREEN}================================================${NO_COLOR}\n"
