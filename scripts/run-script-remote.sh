#!/bin/bash

if [[  -z "${IPV4}" ]]; then
  if [[  -f ./scripts/extract-ip.sh ]]; then
    source ./scripts/extract-ip.sh
  else
    source ./extract-ip.sh
  fi
fi

function remoteWhoAmI () {
  echo "whoami"
  ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" << 'ENDSSH'
    whoami
ENDSSH
}

function login () {
  if [ "$(hcloud server list | grep ${SERVER_NAME})" ]; then

    if [[  -z "${IPV4}" ]]; then
     export IPV4=$(hcloud server ip "${SERVER_NAME}")
    fi
    echo "login to server ${SERVER_NAME} with ubuntu@${IPV4}"
    ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4"
  else
    echo "server ${SERVER_NAME} does not exist!"
  fi
}
