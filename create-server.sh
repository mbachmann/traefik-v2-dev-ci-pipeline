#!/bin/bash

source ./scripts/environment.sh
source ./scripts/create-ssh-key.sh
source ./scripts/dns.sh

echo "Configuration in environment.sh"
printEnvironment

cd "${PRJ_ROOT_DIR}/hcloud" || exit
hcloud server create --image "${SERVER_IMAGE}" --type "${SERVER_TYPE}" --location "${SERVER_LOCATION}" --name "${SERVER_NAME}" --user-data-from-file cloud-init.yml --ssh-key "${SSH_KEY_NAME}"

if [ "${USE_HETZNER_DNS_API}" == "true" ] ; then
   addDnsRecord "${MONITOR_SVC}.${SERVER_NAME}"
   addDnsRecord "${PORTAINER_SVC}.${SERVER_NAME}"
   addDnsRecord "${PORTAINER_EDGE_SVC}.${SERVER_NAME}"
   addDnsRecord "${BLOG_SVC}.${SERVER_NAME}"
   addDnsRecord "${DBADMIN_SVC}.${SERVER_NAME}"
   addDnsRecord "${TODO_H2_SVC}.${SERVER_NAME}"
   addDnsRecord "${TODO_MYSQL_SVC}.${SERVER_NAME}"
fi
