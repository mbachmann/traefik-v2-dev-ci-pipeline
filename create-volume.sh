#!/bin/bash

source ./environment.sh

if [ ! "$(hcloud volume list | grep ${VOLUME_NAME})" ]; then
  echo "Creating and attaching volume name storage01 ..."
  hcloud volume create --format ext4 --server $SERVER_NAME --size 10 --name ${VOLUME_NAME} --automount
else
  hcloud volume attach ${VOLUME_NAME} --server $SERVER_NAME  --automount
fi

if [  "$(hcloud volume list | grep ${VOLUME_NAME})" ]; then
  export LINUXVOL=$(hcloud volume describe ${VOLUME_NAME} | grep Linux |  sed  -e 's/^.*://' | sed -e 's/^[[:space:]]*//')

  # sudo mkdir /mnt/${VOLUME_NAME}
  # sudo mount -o discard,defaults ${LINUXVOL} /mnt/${VOLUME_NAME}
  # echo "${LINUXVOL} /mnt/${VOLUME_NAME} ext4 discard,nofail,defaults 0 0" | sudo tee -a /etc/fstab
fi
