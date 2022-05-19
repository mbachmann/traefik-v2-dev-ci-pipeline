#!/bin/bash

source ./scripts/environment.sh

echo "Configured Enviroment in environment.sh"
echo SERVER_NAME="${SERVER_NAME}"
echo SERVER_TYPE="${SERVER_TYPE}"
echo SERVER_IMAGE="${SERVER_IMAGE}"
echo SERVER_LOCATION="${SERVER_LOCATION}"
echo VOLUME_NAME="${VOLUME_NAME}"
echo BASE_URL="${BASE_URL}"
echo PRJ_ROOT_DIR="${PRJ_ROOT_DIR}"
echo SSH_KEY_NAME=${HCLOUD_USER_NAME}@${SERVER_NAME}


cd "${PRJ_ROOT_DIR}/hcloud" || exit
hcloud server create --image "${SERVER_IMAGE}" --type "${SERVER_TYPE}" --location "${SERVER_LOCATION}" --name "${SERVER_NAME}" --user-data-from-file cloud-init.yml --ssh-key "${SSH_KEY_NAME}"

