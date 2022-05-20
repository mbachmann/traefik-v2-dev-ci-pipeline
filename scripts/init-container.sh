#!/bin/bash

CUR_SCRIPTDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "current script folder: $CUR_SCRIPTDIR"
source "$CUR_SCRIPTDIR"/environment.sh

echo "project root folder: ${PRJ_ROOT_DIR}"

# make all .sh files executable
find "${PRJ_ROOT_DIR}" -type f -iname "*.sh" -exec chmod +x {} \;


echo "starting containers"
cd "${PRJ_ROOT_DIR}/traefik" || exit
./start-traefik.sh
cd "${PRJ_ROOT_DIR}" || exit



