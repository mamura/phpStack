#!/bin/bash

# Iniciando o Docker
sudo service docker start

# Alterando as configurações de rede
sudo ifconfig lo:0 172.254.254.254 up
sudo systemctl stop systemd-resolve

# Iniciando a stack de desenvolvimento
docker-compose up -d

# alterando o arquivo resolv.conf
linha=$(grep -n "nameserver" /etc/resolv.conf | cut -f1 -d: | tail -1)
sudo sed -i "${linha}d" /etc/resolv.conf
sudo sed -i "${linha}i nameserver 127.0.0.1" /etc/resolv.conf

# Aqui você pode adicionar outros containers a serem inicializados
