#!/bin/bash

source ./environment.sh

if [ ! "$(hcloud volume list | grep ${VOLUME_NAME})" ]; then
  echo "Detaching volume with name ${VOLUME_NAME} ..."
  hcloud volume detach $VOLUME_NAME
fi
if [ ! "$(hcloud server list | grep ${SERVER_NAME})" ]; then
  echo "Deleting server with name ${SERVER_NAME} ..."
  hcloud server delete $SERVER_NAME
fi
ssh-keygen -R "$IPV4"
