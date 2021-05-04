<h1 align="center">Docker Lemp Stack</h1>

Utilizado para provisionar um ambiente local de desenvolvimento com servidor NGINX PHP MYSQL.
[Tutorial no Youtube](https://youtu.be/ZMP8dhkPiF0)

# Containers

## Container - PHP
- Versão 7.3-fpm
- Xdebug 2.9.8
- Libs = GD, IMAGICK, SOAP, PDO

## Container - Nginx
- Versão Latest

## Container - Mysql
- Versão 8.0

## Container - Mailhog
- Versão 1.0.0

<br/>

# Pré requisitos 
<p> Para o uso deste repositório você deve ter instalado em seu sistema.</p>

- [Docker](https://www.docker.com/)
- [Docker-compose](https://github.com/docker/compose)
- [Mkcert](https://github.com/FiloSottile/mkcert)

<br/>

# Setup Inicial

<p>Clone o repositório para uma pasta de projetos na sua home ex: ~/Workspace</p>

```
$ cd ~/Workspace

$ git clone https://github.com/digoartmusic/docker-lemp-stack.git Docker-Lemp
```

<p>Aplique as permissões de execução nos arquivos do diretório cli</p>

```
$ chmod +x Docker-Lemp/cli/*
```

<br/>

# Criar site
<p>Acesse a pasta de provisionamento ex: ~/Workspace/Docker-Lemp execute o comando</p>

```
$ sudo cli/site-create.sh dev.exemplo.com.br
```

<p> Após a finalização da Build você tera a pasta do site em ~/Wordscape/dev.exemplo.com.br</p>

```
├── certs
├── cli
├── docker
│   ├── mysql
│   ├── nginx
│   │   └── log
│   └── php
└── public
```

<br/>

# Iniciar o Site
<p>Acesse a pasta do site ex: ~/Workspace/dev.exemplo.com.br e execute o comando</p>

```
$ ./site_start.sh
```

# Parar o Site
<p>Acesse a pasta do site ex: ~/Workspace/dev.exemplo.com.br e execute o comando</p>

```
$ ./site_stop.sh
```

# Excluir Site
<p>Acesse a pasta de provisionamento ex: ~/Workspace/Docker-Lemp execute o comando</p>

```
$ sudo cli/site-delete.sh dev.exemplo.com.br
```
