#!/bin/bash

# Add or remove a vhost ex. myapp.local. This will modify /etc/hosts

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;93m'
NC='\033[0m'

ETC_HOSTS=/etc/hosts
IP=$3

HOSTNAME=$1
QUESTION=$2

if [ ${QUESTION} == "a" ]; then

	HOSTS_LINE="$IP\t$HOSTNAME"

	if [ -n "$(grep $HOSTNAME /etc/hosts)" ]; then
		echo -e ${YELLOW}"$HOSTNAME already exists: $(grep $HOSTNAME $ETC_HOSTS) ${NC}"
	else
		echo -e ${GREEN}"Adding $HOSTNAME to your $ETC_HOSTS ${NC}"
		sh -c -e "echo '$HOSTS_LINE' >> /etc/hosts"

		if [ -n "$(grep $HOSTNAME /etc/hosts)" ]; then
			echo -e ${GREEN}"$HOSTNAME was added succesfully \n $(grep $HOSTNAME /etc/hosts) ${NC}"
		else
			echo -e ${RED}"Failed to Add $HOSTNAME, Try again! ${NC}"
		fi
	fi

fi

if [ ${QUESTION} == "r" ]; then

	if [ -n "$(grep $HOSTNAME /etc/hosts)" ]; then
		echo -e ${GREEN}"$HOSTNAME Found in your $ETC_HOSTS, Removing now... ${NC}"

		cp $ETC_HOSTS /etc/hostsbkp && sed -i "/$HOSTNAME/d" /etc/hostsbkp
		cp /etc/hostsbkp $ETC_HOSTS 

	else
		echo -e ${RED}"$HOSTNAME was not found in your $ETC_HOSTS ${NC}"
	fi

fi
