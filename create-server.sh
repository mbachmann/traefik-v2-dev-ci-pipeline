#!/bin/bash

export SERVER_NAME=cas-oop-srv-01
export SERVER_TYPE=cx11
export SERVER_IMAGE=ubuntu-20.04
export SERVER_LOCATION=hel1

# Absolute path to this script, e.g. /home/user/traefik-v2-dev-ci-pipeline/init.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/traefik-v2-dev-ci-pipeline
CUR_DIR=$(dirname "$SCRIPT")
echo $CUR_DIR

cd $CUR_DIR/hcloud
hcloud server create --image ubuntu-20.04 --type cx11 --location hel1 --name cas-oop-srv-01 --user-data-from-file cloud-init.yml

