#!/bin/bash

if [[ -z "${SERVER_NAME}" ]]; then
  echo "load environment.sh in extract-ip.sh"
  if [[ -f ./scripts/environment.sh ]]; then
    source ./scripts/environment.sh
  else
    source ./environment.sh
  fi
fi

function createAndAttachVolume() {

  if [ "${USE_VOLUME}" == "true" ]; then
    if [ "$(hcloud server list | grep ${SERVER_NAME})" ]; then
      if [ ! "$(hcloud volume list | grep ${VOLUME_NAME})" ]; then
        if [[ -z "${IPV4}" ]]; then
          export IPV4=$(hcloud server ip "${SERVER_NAME}")
        fi
        echo "Creating and attaching volume name ${VOLUME_NAME} to server ${SERVER_NAME}..."
        hcloud volume create --format ext4 --server $SERVER_NAME --size 10 --name ${VOLUME_NAME} --automount
        if [ "$(hcloud volume list | grep ${VOLUME_NAME})" ]; then
          export LINUXVOL=$(hcloud volume describe ${VOLUME_NAME} | grep Linux | sed -e 's/^.*://' | sed -e 's/^[[:space:]]*//')
          echo "mount volume in server /mnt/${VOLUME_MOUNT_NAME} to ${LINUXVOL}, update /etc/fstab"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "sudo mkdir /mnt/${VOLUME_MOUNT_NAME}"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "sudo mount -o discard,defaults ${LINUXVOL} /mnt/${VOLUME_MOUNT_NAME}"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "echo '${LINUXVOL} /mnt/${VOLUME_MOUNT_NAME} ext4 discard,nofail,defaults 0 0' | sudo tee -a /etc/fstab"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "sudo chown -R ubuntu:ubuntu /mnt/${VOLUME_MOUNT_NAME}"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "sudo chmod -R g+rwx /mnt/${VOLUME_MOUNT_NAME}"
        fi
      else
        hcloud volume attach ${VOLUME_NAME} --server $SERVER_NAME --automount
        if [[ ! -d "/mnt/${VOLUME_MOUNT_NAME}" ]]; then
          export LINUXVOL=$(hcloud volume describe ${VOLUME_NAME} | grep Linux | sed -e 's/^.*://' | sed -e 's/^[[:space:]]*//')
          echo "mount volume in server /mnt/${VOLUME_MOUNT_NAME} to ${LINUXVOL}, update /etc/fstab"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "sudo mkdir /mnt/${VOLUME_MOUNT_NAME}"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "sudo mount -o discard,defaults ${LINUXVOL} /mnt/${VOLUME_MOUNT_NAME}"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "echo '${LINUXVOL} /mnt/${VOLUME_MOUNT_NAME} ext4 discard,nofail,defaults 0 0' | sudo tee -a /etc/fstab"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "sudo chown -R ubuntu:ubuntu /mnt/${VOLUME_MOUNT_NAME}"
          ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "${LOCAL_DIR}"/id_rsa ubuntu@"$IPV4" "sudo chmod -R g+rwx /mnt/${VOLUME_MOUNT_NAME}"
        fi
      fi
    else
      echo "No volume enabled; for volumes set USE_VOLUME=true in environment.sh"
    fi

  fi
}

function detachVolume() {
  if [ "$(hcloud volume list | grep "${VOLUME_NAME}")" ]; then
    echo "Detaching volume with name ${VOLUME_NAME} ..."
    hcloud volume detach "$VOLUME_NAME"
  fi
}

function deleteVolume() {
  if [ "$(hcloud volume list | grep "${VOLUME_NAME}")" ]; then
    echo "Deleting volume with name ${VOLUME_NAME} ..."
    hcloud volume delete "$VOLUME_NAME"
  fi
}
