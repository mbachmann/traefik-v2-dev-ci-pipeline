#!/bin/bash

echo "** init-server **"
CUR_SERVERDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CUR_SCRIPTDIR="${CUR_SERVERDIR}"/../scripts

source "${CUR_SCRIPTDIR}"/environment.sh
export "${CUR_SERVERDIR}"
export "${CUR_SCRIPTDIR}"

echo "current server folder: ${CUR_SERVERDIR}"
echo "script folder: ${CUR_SCRIPTDIR}"
echo "project root folder: ${PRJ_ROOT_DIR}"
echo "persistent volume folder: ${CONTAINER_PERSISTENT_VOLUME}"

# make all .sh files executable
find "${PRJ_ROOT_DIR}" -type f -iname "*.sh" -exec chmod +x {} \;

# Initialize the IPV4 variable
getMyIp

# move tokens if exist from /home/ubuntu/local /home/ubuntu/"${GIT_PROJECT_NAME}"/local
mv  -v /home/ubuntu/local/* /home/ubuntu/"${GIT_PROJECT_NAME}"/local

webmin_root_password_filename="${CONTAINER_PERSISTENT_VOLUME}/secrets/webmin_root_password.txt"
webmin_root_password=$(readFromFile ${webmin_root_password_filename} ubuntu)

# Adjust the root password for webmin login
sudo sh -c "echo root:${webmin_root_password} | chpasswd"

echo "configure server"
# =============   Execute Scripts    =======================
cd "${PRJ_ROOT_DIR}/server" || exit
./docker-to-volume.sh
./configure-localhost-mysql-database.sh
./configure-localhost-postgres-database.sh
./configure-webmin.sh

# ============ Call INIT Container Script =================
./init-containers.sh

