#!/bin/bash

CUR_SCRIPTDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "current script folder: $CUR_SCRIPTDIR"
source "$CUR_SCRIPTDIR"/environment.sh

echo "project root folder: ${PRJ_ROOT_DIR}"

if [ "${USE_VOLUME}" == "true" ]; then
  export CONTAINER_PERSISTENT_VOLUME="${CONTAINER_VOLUME_DATA_FOLDER}"
else
  export CONTAINER_PERSISTENT_VOLUME="${CONTAINER_USER_DATA_FOLDER}"
fi

echo "persistent volume folder: ${CONTAINER_PERSISTENT_VOLUME}"

# make all .sh files executable
find "${PRJ_ROOT_DIR}" -type f -iname "*.sh" -exec chmod +x {} \;

echo "starting containers"
cd "${PRJ_ROOT_DIR}/traefik" || exit
./start-traefik.sh
cd "${PRJ_ROOT_DIR}" || exit



