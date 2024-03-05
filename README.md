# pnetlabv6
HTML

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instalação do PNETLAB V6 - SanderEthx</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            padding: 20px;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 5px;
        }
        h1 {
            font-size: 24px;
            margin-bottom: 20px;
        }
        p {
            font-size: 16px;
            line-height: 1.5;
        }
        code {
            font-family: monospace;
            background-color: #f5f5f5;
            padding: 2px 4px;
            border: 1px solid #ddd;
            border-radius: 3px;
        }
        a {
            color: #007bff;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Instalação do PNETLAB V6</h1>
        <p><strong>SanderEthx</strong></p>
        <p>Assista ao tutorial no <a href="https://www.youtube.com/SanderEthx" target="_blank">Youtube.com/SanderEthx</a></p>
        <ol>
            <li>Download do <a href="https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-live-server-amd64.iso" target="_blank">ubuntu-20.04.6-live-server-amd64.iso</a></li>
            <li>Instale o Ubuntu Server em um ambiente bare metal ou virtualizado (Proxmox, VMware ESXi, VMware Workstation, VirtualBox, QEMU, etc.)</li>
            <li>Atualize o ambiente</li>
            <li>Execute o seguinte comando no terminal:</li>
        </ol>
        <code>bash -c "$(curl -sL https://labhub.eu.org/api/raw/?path=/UNETLAB%20I/upgrades_pnetlab/Focal/install_pnetlab_v6.sh)"</code>
        <p>Para instalar o <a href="https://github.com/ishare2-org/" target="_blank">ishare2</a>, siga as instruções no <a href="https://github.com/ishare2-org/ishare2-cli/blob/main/README.md" target="_blank">README</a>:</p>
        <code>wget -O /usr/sbin/ishare2 https://raw.githubusercontent.com/ishare2-org/ishare2-cli/main/ishare2 && chmod +x /usr/sbin/ishare2 && ishare2</code>
        <p>Baixe o <a href="https://github.com/obscur95/gns3-server/blob/master/IOU/CiscoIOUKeygen.py" target="_blank">CiscoIOUKeygen.py</a> para gerar chaves para o Cisco IOU.</p>
    </div>
</body>
</html>
