#!/bin/bash

source ./scripts/environment.sh
source ./scripts/dns.sh

if [ "$(hcloud volume list | grep "${VOLUME_NAME}")" ]; then
  echo "Detaching volume with name ${VOLUME_NAME} ..."
  hcloud volume detach "$VOLUME_NAME"
fi
if [ "$(hcloud server list | grep ${SERVER_NAME})" ]; then
  echo "Deleting server with name ${SERVER_NAME} ..."
  hcloud server delete "$SERVER_NAME"
else
    echo "Server with name ${SERVER_NAME} not found!"
fi
# ssh-keygen -R "$IPV4"

if [ "${USE_HETZNER_DNS_API}" == "true" ] ; then
   deleteDnsRecord "${MONITOR_SVC}.${SERVER_NAME}"
   deleteDnsRecord "${PORTAINER_SVC}.${SERVER_NAME}"
   deleteDnsRecord "${PORTAINER_EDGE_SVC}.${SERVER_NAME}"
   deleteDnsRecord "${BLOG_SVC}.${SERVER_NAME}"
   deleteDnsRecord "${DBADMIN_SVC}.${SERVER_NAME}"
   deleteDnsRecord "${TODO_H2_SVC}.${SERVER_NAME}"
   deleteDnsRecord "${TODO_MYSQL_SVC}.${SERVER_NAME}"
fi

