#!/usr/bin/env bash
#
# Configuração de Ambiente

# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() { echo -e '\e[1;31m'$1'\e[m'; exit 1; }

# Variables
NGINX_DIR='./docker/nginx'
WEB_DIR='./public'
SSL_DIR='./certs'
USER='www-data'

echo -e "Insira o IP RANGE ex 172.18.0:"
read IP_RANGE

# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root."
[ $# != "1" ] && die "Usage: $(basename $0) domainName"


# Creating {site} Directory
mkdir -p ../$1
mkdir -p ../$1/cli

cp -R ./docker ../$1
cp docker-compose.yml ../$1
cp ./cli/setup-hosts-file.sh ../$1/cli
cp ./cli/wp-permissions-script.sh ../$1/cli

cd ../$1

# Create nginx config file
cat > $NGINX_DIR/nginx.conf <<EOF

http {

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

    server {

        listen 80;

        listen 443 default_server ssl;

        ssl_certificate /var/www/certs/$1.pem; 
        ssl_certificate_key /var/www/certs/$1-key.pem;

	    server_name $1;
        root /var/www/public;

        index index.php index.html;

        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass php:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }

        error_log /var/log/nginx/error.log;
        access_log /var/log/nginx/access.log;
    }

    server_tokens off;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 15;
    types_hash_max_size 2048;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log off;
    error_log off;
    gzip on;
    gzip_disable "msie6";
    open_file_cache max=100;
    client_max_body_size 12M;
}

events {
  worker_connections  2048;
  multi_accept on;
  use epoll;
}

user www-data;
worker_processes 4;
pid /run/nginx.pid;
daemon off;

EOF

# Creating {public} Directory
mkdir -p $WEB_DIR

# Creating index.html file
cat > $WEB_DIR/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
        <title>$1</title>
        <meta charset="utf-8" />
</head>
<body class="container">
        <header><h1>$1<h1></header>
        <div id="wrapper">

Hello World
</div>
        <footer>© $(date +%Y)</footer>
</body>
</html>
EOF

#Generate .env
cat > .env <<EOF

DB_USER=root
DB_PASSWORD=root
DB_NAME=${1//[-._]/}
DB_HOST=mysql

DOMAIN=$1

IP_RANGE=$IP_RANGE

EOF

# Creating {certs} Directorie
mkdir -p $SSL_DIR

# Get Current Direcoty
current_dir=$PWD

#Generate Certificate
cd certs

mkcert $1

cd $current_dir

chown -R ${SUDO_USER}:${SUDO_USER} ../$1


#Executar o Docker Compose
docker-compose up -d

#Configurar o arquivo de Hosts
chmod +x cli/setup-hosts-file.sh
cli/setup-hosts-file.sh $1 a $IP_RANGE.3

#Mensagem de Finalização
ok "Site Created for $1"