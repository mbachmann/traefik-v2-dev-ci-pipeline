#!/bin/bash

if [[  -f ./scripts/environment.sh ]]; then
  source ./scripts/environment.sh
else
  source ./environment.sh
fi

LOCAL_DIR="${PRJ_ROOT_DIR}/local"

if [[ ! -f "${LOCAL_DIR}/id_rsa" ]]; then
  echo "Creating public and private key  ..."
  ssh-keygen -t rsa -b 4096 -C "ubuntu@hetzner.com" -f "${LOCAL_DIR}/id_rsa" -q -N ""
  if [  "$(hcloud ssh-key list | grep ${SSH_KEY_NAME})" ]; then
    echo "Deleting ssh key ${SSH_KEY_NAME} from https://console.hetzner.cloud/ "
    hcloud ssh-key delete "${SSH_KEY_NAME}"
  fi
  echo "Uploading ssh key ${SSH_KEY_NAME} to https://console.hetzner.cloud/ "
  hcloud ssh-key create --public-key-from-file="${LOCAL_DIR}/id_rsa.pub" --name "${SSH_KEY_NAME}"
fi
