#!/bin/bash

./environment.sh

echo "Configured Enviroment in environment.sh"
echo SERVER_NAME=$SERVER_NAME
echo SERVER_TYPE=$SERVER_TYPE
echo SERVER_IMAGE=$SERVER_IMAGE
echo SERVER_LOCATION=$SERVER_LOCATION
echo VOLUME_NAME=$VOLUME_NAME

# Absolute path to this script, e.g. /home/user/traefik-v2-dev-ci-pipeline/init-container.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/traefik-v2-dev-ci-pipeline
CUR_DIR=$(dirname "$SCRIPT")
echo $CUR_DIR

cd $CUR_DIR/hcloud
hcloud server create --image ubuntu-20.04 --type cx11 --location hel1 --name cas-oop-srv-01 --user-data-from-file cloud-init.yml

