#!/bin/bash

# add scripts
source cli

if [[ `git status --porcelain` ]]; then
  echo "Warning: uncommitted git changes!!"
else
  # No changes
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
   addDnsRecord "${TODO_H2_SVC}"
   addDnsRecord "${TODO_MYSQL_SVC}"
fi

if [ "${USE_VOLUME}" == "true" ]; then
  createAndAttachVolume
fi
