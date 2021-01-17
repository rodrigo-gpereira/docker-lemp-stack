<h1 align="center">Docker Lemp Stack</h1>

Utilizado para provisionar um ambiente local de desenvolvimento com servidor NGINX PHP MYSQL.

# Containers

## Container - PHP
- Versão 7.3-fpm
- Xdebug
- Libs = GD, IMAGICK, SOAP, PDO

## Container - Nginx
- Versão Latest

## Container - Mysql
- Versão 5.7.19

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


# Excluir Site
<p>Acesse a pasta de provisionamento ex: ~/Workspace/Docker-Lemp execute o comando</p>

```
$ sudo cli/site-delete.sh dev.exemplo.com.br
```
