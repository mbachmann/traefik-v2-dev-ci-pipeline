#!/bin/bash

source cli

if [ "$(hcloud server list | grep ${SERVER_NAME})" ]; then
    if [[  -z "${IPV4}" ]]; then
     export IPV4=$(hcloud server ip "${SERVER_NAME}")
    fi
    echo "login to server ${SERVER_NAME} with ubuntu@${IPV4}"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ./local/id_rsa ubuntu@"$IPV4"
else
    echo "server ${SERVER_NAME} does not exist!"
fi


