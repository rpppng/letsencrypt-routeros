#!/bin/bash
CONFIG_FILE=/opt/letsencrypt-routeros/letsencrypt-routeros.settings

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] || [[ -z $5 ]]; then
        echo -e "Usage: $0 or $0 [RouterOS User] [RouterOS Host] [SSH Port] [SSH Private Key] [Domain]\n"
        source $CONFIG_FILE
else
        ROUTEROS_USER=$1
        ROUTEROS_HOST=$2
        ROUTEROS_SSH_PORT=$3
        ROUTEROS_PRIVATE_KEY=$4
        DOMAIN=$5
fi

if [[ -z $ROUTEROS_USER ]] || [[ -z $ROUTEROS_HOST ]] || [[ -z $ROUTEROS_SSH_PORT ]] || [[ -z $ROUTEROS_PRIVATE_KEY ]] || [[ -z $DOMAIN ]]; then
        echo "Check the config file $CONFIG_FILE or start with params: $0 [RouterOS User] [RouterOS Host] [SSH Port] [SSH Private Key] [Domain]"
        echo "Please avoid spaces"
        exit 1
fi

#Create alias for RouterOS command
routeros="ssh -i $ROUTEROS_PRIVATE_KEY $ROUTEROS_USER@$ROUTEROS_HOST -p $ROUTEROS_SSH_PORT"

#Check connection to RouterOS
$routeros /system resource print
RESULT=$?

        echo -e "\nError in: $routeros"
        echo "More info: https://wiki.mikrotik.com/wiki/Use_SSH_to_execute_commands_(DSA_key_login)"
        exit 1
else
        echo -e "\nConnection to RouterOS Successful!\n"
fi

if [ ! -f $CERTIFICATE ] && [ ! -f $KEY ]; then
        echo -e "\nFile(s) not found:\n$CERTIFICATE\n$KEY\n"
        echo -e "Please use CertBot Let'sEncrypt:"
        echo "============================"
        echo "certbot certonly --preferred-challenges=dns --manual -d $DOMAIN --manual-public-ip-logging-ok"
        echo "or (for wildcard certificate):"
        echo "certbot certonly --preferred-challenges=dns --manual -d *.$DOMAIN --manual-public-ip-logging-ok --server https://acme-v02.api.letsencrypt.org/directory"
        echo "==========================="
        echo -e "and follow instructions from CertBot\n"
        exit 1
fi

# add NAT rule
$routeros /ip firewall nat add chain=dstnat dst-port=80 protocol=tcp in-interface-list=WAN comment=certbot-ACME-delete to-addresses=10.7.2.13 action=dst-nat place-before=0

exit 0