#!/bin/bash

HOST_ADDR=${HOST_ADDR:-"10.0.0.4"}
UAA_HOSTNAME=""

if [ -z ${UAA_HOST} ]
 then
        UAA_HOSTNAME="cf.uaa.uaa.svc.cluster.local"
 else
        UAA_HOSTNAME="cf.${UAA_HOST}"
fi

HOSTS_LINE="$HOST_ADDR    $UAA_HOSTNAME"
sudo -- /bin/bash -c -e "echo '$HOSTS_LINE' >> /etc/hosts";
echo "The entry $HOSTS_LINE added to /etc/hosts"
