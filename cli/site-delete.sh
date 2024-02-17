#!/usr/bin/env bash
#
# Nginx - new server block

# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() { echo -e '\e[1;31m'$1'\e[m'; exit 1; }

# Variables

# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root."
[ $# != "1" ] && die "Usage: $(basename $0) domainName"

#parar os containers
docker stop ${1//[._]/}-php-1
docker stop ${1//[._]/}-nginx-1
docker stop ${1//[._]/}-mysql-1
docker stop ${1//[._]/}-mailhog-1
docker stop ${1//[._]/}-wordmove-1

#remover o Arquivos hosts do terminal local
cli/setup-hosts-file.sh $1 r

#Remover os arquivos de configuração e diretório
rm -r ../$1

docker rm -v ${1//[._]/}-php-1
docker rm -v ${1//[._]/}-nginx-1
docker rm -v ${1//[._]/}-mysql-1
docker rm -v ${1//[._]/}-mailhog-1
docker rm -v ${1//[._]/}-wordmove-1

docker network rm ${1//[._]/}_dev-network

ok "Site remove $1"
