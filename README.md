<h2 aligh="center">
 Seguimos com a instalação Bare Metal do PnetLab, onde você pode acompanhar todos os passos através do vídeo no Youtube: https://www.youtube.com/watch?v=6XcsoaGveW4
</h2>

## 📚 Sumário

- [🚀 Instalação PnetLab](#Pnetlab)
- [🚀 Instalação do Ishare2](#Ishare2)
- [🚀 Correção do Arquivo CISCOIOUKeygen.py](#CiscoIOU)
- [🚀 Instalação do Client Pack](#ClientPack)
- [🚀Referências](#Ref)

## 🚀 Instalação PNETLAB<a id="Pnetlab"></a>

- 💎 Realize o Download do Ubuntu Server 20.04.6 LTS
```linux
https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-live-server-amd64.iso
```

- 💎 Instale o Ubuntu Server em um ambiente bare metal ou virtualizado (Proxmox, VMware ESXi, VMware Workstation, VirtualBox, QEMU, etc.)
- 💎 Atualize o Sistema Operacional
- 💎 Realize a instalação do PnetLab através dos comandos:
```linux
curl -fsSL https://raw.githubusercontent.com/sanderethx/pnetlabv6/refs/heads/main/install-pnetlabv6-ethx.sh | bash
```

## 🚀 Instalação do Ishare2<a id="Ishare2"></a>

- 💎 Realize a instalação do ISHARE2 executando o comando abaixo:
```linux
wget -O /usr/sbin/ishare2 https://raw.githubusercontent.com/ishare2-org/ishare2-cli/main/ishare2 && chmod +x /usr/sbin/ishare2 && ishare2
```

## 🚀 Correção do Arquivo CISCOIOUKeygen.py<a id="CiscoIOU"></a>
```linux
#! /usr/bin/python
print("*********************************************************************")
print("Cisco IOU License Generator - Kal 2011, python port of 2006 C version")
print("Modified to work with python3 by c_d 2014")
import os
import socket
import hashlib
import struct

# get the host id and host name to calculate the hostkey
hostid=os.popen("hostid").read().strip()
hostname = socket.gethostname()
ioukey=int(hostid,16)
for x in hostname:
 ioukey = ioukey + ord(x)
print("hostid=" + hostid +", hostname="+ hostname + ", ioukey=" + hex(ioukey)[2:])

# create the license using md5sum
iouPad1 = b'\x4B\x58\x21\x81\x56\x7B\x0D\xF3\x21\x43\x9B\x7E\xAC\x1D\xE6\x8A'
iouPad2 = b'\x80' + 39*b'\0'
md5input=iouPad1 + iouPad2 + struct.pack('!i', ioukey) + iouPad1
iouLicense=hashlib.md5(md5input).hexdigest()[:16]

print("\nAdd the following text to ~/.iourc:")
print("[license]\n" + hostname + " = " + iouLicense + ";\n")
print("You can disable the phone home feature with something like:")
print(" echo '127.0.0.127 xml.cisco.com' >> /etc/hosts\n")
```
## 🚀 Instalação do Client Pack<a id="ClientPack"></a>

Você pode realizar a instalação do Client Pack e acessar os ativos do laboratório através de softwares como MobaXTerm ou Putty.

***[CLIQUE AQUI](https://github.com/sanderethx/pnetlabv6/blob/main/Instala%C3%A7%C3%A3o%20Client%20Pack.md)*** para acessar o guia.

## 🚀 Referências<a id="Ref"></a>
- **LABHUB:** https://labhub.eu.org
- **CISCOIOUKeygen:** https://github.com/obscur95/gns3-server/blob/master/IOU/CiscoIOUKeygen.py
- **ISHARE2:** https://github.com/ishare2-org

