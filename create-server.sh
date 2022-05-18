#!/bin/bash

source ./environment.sh

echo "Configured Enviroment in environment.sh"
echo SERVER_NAME=$SERVER_NAME
echo SERVER_TYPE=$SERVER_TYPE
echo SERVER_IMAGE=$SERVER_IMAGE
echo SERVER_LOCATION=$SERVER_LOCATION
echo VOLUME_NAME=$VOLUME_NAME
echo BASE_URL=$BASE_URL

# Absolute path to this script, e.g. /home/user/traefik-v2-dev-ci-pipeline/init-container.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/traefik-v2-dev-ci-pipeline
CUR_DIR=$(dirname "$SCRIPT")
echo $CUR_DIR

cd $CUR_DIR/hcloud
hcloud server create --image $SERVER_IMAGE --type $SERVER_TYPE --location $SERVER_LOCATION --name $SERVER_NAME --user-data-from-file cloud-init.yml

