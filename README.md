Criei essa Stack para trabalhar com multiplos projetos PHP no Docker, mas ele pode ser facilmente utilizado com projetos de qualquer linguagem.

Para poder executar esse ambiente de desenvolvimento, você deve instalar previamente o docker e o docker-compose.

- [Get Docker](https://docs.docker.com/get-docker/)
- [Install Docker Compose](https://docs.docker.com/compose/install/)

## Criando a dev network
Para permitir que nossos contâineres se comuniquem, precisamos criar uma rede compartilhada, então, execute o comando abaixo:

```bash
docker network create dev-network
```

## DNS Server setup
Para garantir que os projetos funcionem corretamente em seu computador, você deve configurar o servidor DNS primário para 127.0.0.1, então seu computador poderá reconhecer e redirecionar qualquer domínio "*.test" para nosso roteador.

## Linux
Algumas distribuições Linux vem com o serviço systemd-resolve ativado, você precisa desativá-lo, pois ele se vincula a porta [53], que entrará em conflito com a porta do Dnsmasq.

Execute os segiuntes comandos:
```bash
sudo systemctl disable systemd-resolve
sudo systemctl stop systemd-resolve
```

Altere o arquivo resolv.conf:
```bash
ls -jh /etc/resolv.conf
sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolv.conf
```

Se sua distribuição usa o NetworkManager, você deve desabilitar a configuração do dns editando o arquivo **/etc/NetworkManager/NetworkManager.conf** adicionando o parâmetro:
```console
dns=none
```

O NetworkManager.conf final deve ser:
```console
[main]
plugins=ifupdown,keyfile
dns=none

[ifupdown]
managed=false

[device]
wifi.scan-rand-mac-address=no
```

## Run the stack
Junto dessa stack há dois scripts que podem ser executados para fazer todas as instalações e configurações necessárias. Elas foram criadas para rodar em um ambiente Linux utilizando Ubuntu. Cada máquina possui configurações únicas, então esses scripts podem não se comportar como esperado em algumas situações.

O script start-dev.sh inicia a stack e configura o Dnsserver. Já o script init-project.sh faz um clone do projeto Base do git e inicia um container e instala um novo Laravel.

## Standard project docker-compose file
```yaml
services:

  app:
    image: ghcr.io/mamura/php81-fpm:latest
    labels:
      - traefik.http.routers.app.rule(`app.mamura.test`)
    volumes:
      - ./src:/src
    environment:
      - PROJECT_WEBROOT=/src/public

networks:
  default:
    name: dev-network
    external: true

## WSL2 Configuration
Após a atualização do WSL com melhorias para o compartilhamento de redes entre o Linux e Windows, tivemos algumas novas configurações para fazer
essa stack funcionar corretamente. Adicionei ao projeto um arquivo (.wslconfig) que deve ser adicionadono ao diretório do seu usuário no windows (C:\Users\<NOME_USUARIO>).

Além disso, devemos liberar o uso das portas necessárias, usando esse comando no Terminal do Windows:

```console
 New-NetFirewallRule -DisplayName "WSL2 Port Bridge" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80,443,10000,3000,5000
 ```
      