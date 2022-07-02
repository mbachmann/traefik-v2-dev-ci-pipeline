#!/bin/bash

function createServer() {

  if [[ `git status --porcelain` ]]; then
    echo "Warning: uncommitted git changes!!"
    return 1
  fi

  echo "Configuration in environment.sh"
  printEnvironment

  # Copy ssh public key to authorized keys
  addPublicKeyToCloudInit


  if [ "$(hcloud server list | grep ${SERVER_NAME})" ]; then
    echo "The Server ${SERVER_NAME} already exists!"
    return 1
  fi

  cd "${PRJ_ROOT_DIR}/hcloud" || exit
  hcloud server create --image "${SERVER_IMAGE}" --type "${SERVER_TYPE}" --location "${SERVER_LOCATION}" --name "${SERVER_NAME}" --user-data-from-file cloud-init.yml --ssh-key "${SSH_KEY_NAME}"

  cd "${PRJ_ROOT_DIR}" || exit

  if [ "${USE_HETZNER_DNS_API}" == "true" ] ; then
    createAllDNSRecords
  fi

  if [ "${USE_VOLUME}" == "true" ]; then
    createAndAttachVolume
  fi

  # Copy Tokens und ssh key pair to remote based on COPY_TOKEN and COPY_SSH_KEYPAIR in environment.sh
  copyLocalToRemote

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


function deleteServer() {

  if [ "$(hcloud volume list | grep "${VOLUME_NAME}")" ]; then
    echo "Detaching volume with name ${VOLUME_NAME} ..."
    hcloud volume detach "$VOLUME_NAME"
  fi
  if [ "$(hcloud server list | grep ${SERVER_NAME})" ]; then
    echo "Deleting server with name ${SERVER_NAME} ..."
    hcloud server delete "$SERVER_NAME"
  else
      echo "Server with name ${SERVER_NAME} not found!"
      return 1
  fi
  # ssh-keygen -R "$IPV4"

  if [ "${USE_HETZNER_DNS_API}" == "true" ] ; then
     deleteAllDNSRecords
  fi


}

#**
# $1 source file to copy, e.g. "${LOCAL_DIR}"/id_rsa
# $2 remote folder to copy, e.g. /home/ubuntu/.ssh
function copyFileToRemote () {
   sourcefile="$1"
   target="$2"
   scp  -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa "${sourcefile}"  ubuntu@"$IPV4":"${target}"
   unset sourcefile target
}

function copySSHPairToRemote () {
   copyFileToRemote "${LOCAL_DIR}"/id_rsa.pub /home/ubuntu/.ssh
   copyFileToRemote "${LOCAL_DIR}"/id_rsa /home/ubuntu/.ssh
   ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "sudo chmod 600 /home/ubuntu/.ssh/id_rsa"
}

function copyLocalToRemote () {
   if [ "${COPY_TOKEN}" == "true" ]; then
        mkdir -p /home/ubuntu/local
        copyFileToRemote "${LOCAL_DIR}"/hcloud-token.local /home/ubuntu/local
        copyFileToRemote "${LOCAL_DIR}"/dns-token.local /home/ubuntu/local
   fi
   if [ "${COPY_SSH_KEYPAIR}" == "true" ]; then
     copySSHPairToRemote
   fi
}

function getContainerIp () {
   containerName="$1"
   docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $containerName
   unset containerName
}


function replaceRepositoryNameInCloudInit () {
  if [[ "${GIT_ORIG_REPO}" != "${GIT_REPO}" ]] ; then
    origName="${GIT_ORIG_REPO}"
    newName="${GIT_REPO}"
    sed -i "s#${origName}#${newName}#g" "${PRJ_ROOT_DIR}/hcloud/cloud-init.yml"
    unset origName newName
  fi

}
