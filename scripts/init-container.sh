#!/bin/bash

CUR_SCRIPTDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "current script folder: $CUR_SCRIPTDIR"
source "$CUR_SCRIPTDIR"/environment.sh

echo "project root folder: ${PRJ_ROOT_DIR}"

echo "persistent volume folder: ${CONTAINER_PERSISTENT_VOLUME}"

# make all .sh files executable
find "${PRJ_ROOT_DIR}" -type f -iname "*.sh" -exec chmod +x {} \;

# Initialize the IPV4 variable
getMyIp

echo "starting containers"
# ============ REVERSE PROXY =================
cd "${PRJ_ROOT_DIR}/traefik" || exit
./start-webmin.sh
./start-traefik.sh

# ============ PORTAINER  =================
cd "${PRJ_ROOT_DIR}/containers/portainer" || exit
./start-portainer.sh

# ============ WORD PRESS  =================
cd "${PRJ_ROOT_DIR}/containers/wordpress" || exit
./start-wordpress.sh

# ========== SPRING BOOT TODOS  =================
cd "${PRJ_ROOT_DIR}/containers/todo" || exit
./start-todo-h2.sh

# ========== SPRING BOOT DEMO-INITIAL  =================
cd "${PRJ_ROOT_DIR}/containers/demo-initial" || exit
./start-demo-initial-h2.sh


cd "${PRJ_ROOT_DIR}" || exit

