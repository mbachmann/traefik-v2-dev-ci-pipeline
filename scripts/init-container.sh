#!/bin/bash

if [[  -f ./scripts/environment.sh ]]; then
  source ./scripts/environment.sh
else
  source ./environment.sh
fi

echo "project root folder: ${PRJ_ROOT_DIR}"

# make all .sh files executable
find "${PRJ_ROOT_DIR}" -type f -iname "*.sh" -exec chmod +x {} \;



echo "starting containers"
cd "${PRJ_ROOT_DIR}/traefik" || exit
./start-traefik.sh
cd "${PRJ_ROOT_DIR}" || exit



