#!/bin/bash

function createServer() {

  if [[ `git status --porcelain` ]]; then
    echo "Warning: uncommitted git changes!!"
    return 1
  fi

  echo "Configuration in environment.sh"
  printEnvironment

  addPublicKeyToCloudInit

  if [ "$(hcloud server list | grep ${SERVER_NAME})" ]; then
    echo "The Server ${SERVER_NAME} already exists!"
    return 1
  fi

  cd "${PRJ_ROOT_DIR}/hcloud" || exit
  hcloud server create --image "${SERVER_IMAGE}" --type "${SERVER_TYPE}" --location "${SERVER_LOCATION}" --name "${SERVER_NAME}" --user-data-from-file cloud-init.yml --ssh-key "${SSH_KEY_NAME}"

  if [ "${USE_HETZNER_DNS_API}" == "true" ] ; then
     addDnsRecord "${MONITOR_SVC}"
     addDnsRecord "${PORTAINER_SVC}"
     addDnsRecord "${PORTAINER_EDGE_SVC}"
     addDnsRecord "${BLOG_SVC}"
     addDnsRecord "${DBADMIN_SVC}"
     addDnsRecord "${DB_PHP_MYADMIN_SVC}"
     addDnsRecord "${TODO_H2_SVC}"
     addDnsRecord "${TODO_MYSQL_SVC}"
  fi

  if [ "${USE_VOLUME}" == "true" ]; then
    createAndAttachVolume
  fi

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
     deleteDnsRecord "${MONITOR_SVC}"
     deleteDnsRecord "${PORTAINER_SVC}"
     deleteDnsRecord "${PORTAINER_EDGE_SVC}"
     deleteDnsRecord "${BLOG_SVC}"
     deleteDnsRecord "${DBADMIN_SVC}"
     deleteDnsRecord "${DB_PHP_MYADMIN_SVC}"
     deleteDnsRecord "${TODO_H2_SVC}"
     deleteDnsRecord "${TODO_MYSQL_SVC}"
  fi


}