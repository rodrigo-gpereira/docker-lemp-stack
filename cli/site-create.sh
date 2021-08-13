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
WORDMOVE_DIR='./wordmove'
USER='www-data'
ROOTCA_PEM='/home/'${SUDO_USER}'/.local/share/mkcert/rootCA.pem'

LAST_IP=`docker inspect -f '{{.IPAM.Config}} - {{.Name}}' $(docker network ls --format "{{.Name}}") | sort -h | grep -E 172 | awk -F. END'{print $2+1}'`

IP_RANGE='172.'$LAST_IP'.0'

#echo -e "Insira o IP RANGE ex 172.18.0:"
#read IP_RANGE

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

        location ~* \.(eot|ttf|woff|woff2)$ {
	    add_header Access-Control-Allow-Origin *;
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

#Generate site_start.sh
cat > site_start.sh <<EOF

#!/usr/bin/env bash
#
# Iniciar o ambiente desenvolvimento

docker-compose up -d
docker exec -it ${1//[._]/}_php_1 /var/www/cli/setup-hosts-file.sh $1 a $IP_RANGE.3

#configurar o certificado RootCa no container php
docker exec -it ${1//[._]/}_php_1 mkdir /usr/local/share/ca-certificates/extra
docker exec -it ${1//[._]/}_php_1 cp /var/www/certs/rootCA.pem /usr/local/share/ca-certificates/extra/rootCA.crt
docker exec -it ${1//[._]/}_php_1 update-ca-certificates

EOF

#Generate site_stop.sh
cat > site_stop.sh <<EOF

#!/usr/bin/env bash
#
# Parar o Ambiente de Desenvolvimento

docker exec -it ${1//[._]/}_php_1 /var/www/cli/setup-hosts-file.sh $1 r $IP_RANGE.3
docker-compose stop

EOF

# Creating {Wordmove} Directory
mkdir -p $WORDMOVE_DIR

#Generate Wordmove File
cat > $WORDMOVE_DIR/Movefile.yml <<EOF

global:
  sql_adapter: default

local:
  vhost: "$1"
  wordpress_path: "/var/www/public" # use an absolute path here

  database:
    name: "${1//[-._]/}"
    user: "root"
    password: "root"
    host: "mysql"
    charset: "utf8mb4"

  # paths: # you can customize wordpress internal paths
  #   wp_config: "wp-config-custom.php"
  #   wp_content: "wp-content"
  #   uploads: "wp-content/uploads"
  #   plugins: "wp-content/plugins"
  #   mu_plugins: "wp-content/mu-plugins"
  #   themes: "wp-content/themes"
  #   languages: "wp-content/languages"

mirror:
  vhost: "<%= ENV['MIRROR_HOST'] %>"
  wordpress_path: "<%= ENV['MIRROR_WP_PATH'] %>" # use an absolute path here

  database:
    name: "<%= ENV['MIRROR_DB_NAME'] %>"
    user: "<%= ENV['MIRROR_DB_USER'] %>"
    password: "<%= ENV['MIRROR_DB_PASS'] %>"
    host: "<%= ENV['MIRROR_DB_HOST'] %>"
    #port: "3308" # Use just in case you have exotic server config
    mysqldump_options: "--max_allowed_packet=50MB" # Only available if using SSH

  forbid:
    push:
      db: true
      plugins: true
      themes: true
      languages: true
      uploads: true
      mu-plugins: true

  hooks:
    pull:
      after:
        - command: 'chown -R www-data:www-data /var/www/public'
          where: local

  exclude:
    - ".git/"
    - ".env"
    - ".gitignore"
    - ".sass-cache/"
    - ".htaccess"
    - "bin/"
    - "tmp/*"
    - "Gemfile*"
    - "Movefile.yml"
    - "wp-config.php"
    - "wp-content/*.sql"
    - "ee-admin/"

  ssh:
    host: "<%= ENV['MIRROR_HOST_IP'] %>"
    user: "<%= ENV['MIRROR_HOST_USER'] %>"
    password: "<%= ENV['MIRROR_HOST_PASS'] %>"
    port: 22
    rsync_options: "--chmod=755"

prod:
  vhost: "<%= ENV['PROD_HOST'] %>"
  wordpress_path: "<%= ENV['PROD_WP_PATH'] %>" # use an absolute path here

  database:
    name: "<%= ENV['PROD_DB_NAME'] %>"
    user: "<%= ENV['PROD_DB_USER'] %>"
    password: "<%= ENV['PROD_DB_PASS'] %>"
    host: "<%= ENV['PROD_DB_HOST'] %>"
    #port: "3308" # Use just in case you have exotic server config
    mysqldump_options: "--max_allowed_packet=50MB" # Only available if using SSH

  forbid:
    push:
      db: true
      plugins: true
      themes: true
      languages: true
      uploads: true
      mu-plugins: true

  hooks:
    pull:
      after:
        - command: 'chown -R www-data:www-data /var/www/public'
          where: local

  exclude:
    - ".git/"
    - ".env"
    - ".gitignore"
    - ".sass-cache/"
    - ".htaccess"
    - "bin/"
    - "tmp/*"
    - "Gemfile*"
    - "Movefile.yml"
    - "wp-config.php"
    - "wp-content/*.sql"
    - "ee-admin/"

  ssh:
    host: "<%= ENV['PROD_HOST_IP'] %>"
    user: "<%= ENV['PROD_HOST_USER'] %>"
    password: "<%= ENV['PROD_HOST_PASS'] %>"
    port: 22
    rsync_options: "--chmod=755"

EOF

#Generate Wordmove .env file
cat > $WORDMOVE_DIR/.env <<EOF

#MIRROR Enviroment

##MIRROR_HOST=""
##MIRROR_WP_PATH=""
##MIRROR_DB_NAME=""
##MIRROR_DB_USER=""
##MIRROR_DB_PASS=""
##MIRROR_DB_HOST=""
##MIRROR_HOST_IP=""
##MIRROR_HOST_USER=""
##MIRROR_HOST_PASS=""

#PROD Enviroment

##PROD_HOST=""
##PROD_WP_PATH=""
##PROD_DB_NAME=""
##PROD_DB_USER=""
##PROD_DB_PASS=""
##PROD_DB_HOST=""
##PROD_HOST_IP=""
##PROD_HOST_USER=""
##PROD_HOST_PASS=""

EOF

#permissão de execução
chmod +x site_start.sh
chmod +x site_stop.sh

# Creating {certs} Directorie
mkdir -p $SSL_DIR

# Get Current Direcoty
current_dir=$PWD

#Generate Certificate
cd certs

#copia os arquivo de RootCa
cp $ROOTCA_PEM rootCA.pem

chown -R ${SUDO_USER}:${SUDO_USER} ../

sudo -u ${SUDO_USER} mkcert $1

cd $current_dir

#Configurar o arquivo de Hosts
chmod +x cli/setup-hosts-file.sh
cli/setup-hosts-file.sh $1 a $IP_RANGE.3

#Executar o Docker Compose
./site_start.sh

#configurar o certificado RootCa no container php
docker exec -it ${1//[-._]/}_php_1 mkdir /usr/local/share/ca-certificates/extra
docker exec -it ${1//[-._]/}_php_1 cp /var/www/certs/rootCA.pem /usr/local/share/ca-certificates/extra/rootCA.crt
docker exec -it ${1//[-._]/}_php_1 update-ca-certificates

#Mensagem de Finalização
ok "Site Created for $1"

ok "Aguarde 5 segundos"
sleep 5s

#force Docker Compose Mysql
ok "Reiniciar os container criados"

./site_stop.sh
ok "Aguarde 5 segundos"
sleep 5s

./site_start.sh