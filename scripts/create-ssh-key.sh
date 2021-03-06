#!/bin/bash

if [[  -z "${PRJ_ROOT_DIR}" ]]; then
    echo "load environment.sh in create-ssh-key.sh"
  if [[  -f ./scripts/environment.sh ]]; then
    source ./scripts/environment.sh
  else
    source ./environment.sh
  fi
fi

LOCAL_DIR="${PRJ_ROOT_DIR}/local"

if [[ ! -f "${LOCAL_DIR}/id_rsa" ]]; then
  echo "Creating public and private key  ..."
  ssh-keygen -t rsa -C "${SSH_KEY_NAME}" -f "${LOCAL_DIR}/id_rsa" -q -N ""
  if [  "$(hcloud ssh-key list | grep ${SSH_KEY_NAME})" ]; then
    echo "Deleting ssh key ${SSH_KEY_NAME} from https://console.hetzner.cloud/ "
    hcloud ssh-key delete "${SSH_KEY_NAME}"
  fi
  echo "Uploading ssh key ${SSH_KEY_NAME} to https://console.hetzner.cloud/ "
  hcloud ssh-key create --public-key-from-file="${LOCAL_DIR}/id_rsa.pub" --name "${SSH_KEY_NAME}"
fi


function addPublicKeyToCloudInit() {

  PUB_KEY=$(cat "${LOCAL_DIR}/id_rsa.pub")
  HCLOUD_DIR="${PRJ_ROOT_DIR}/hcloud"

  if grep -q "${PUB_KEY}" "${HCLOUD_DIR}"/cloud-init.yml
  then
      echo "public key found in ${HCLOUD_DIR}/cloud-init.yml"
  else
      echo "public key not found in ${HCLOUD_DIR}/cloud-init.yml"
      echo "adding public key to ${HCLOUD_DIR}/cloud-init.yml"

      pattern='ssh_authorized_keys:'
      line="      - ${PUB_KEY}"
      file="${HCLOUD_DIR}"/cloud-init.yml
      tempfile="${HCLOUD_DIR}"/cloud-init.yml.tmp
      awk -vpattern="${pattern}" -vline="${line}" '$0 ~ pattern {print; print line; next} 1' "${file}" > "${tempfile}" && mv -f "${tempfile}" "${file}"
      unset line pattern file tempfile
  fi
}
