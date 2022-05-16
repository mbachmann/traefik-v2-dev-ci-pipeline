#!/bin/bash

# Absolute path to this script, e.g. /home/user/traefik-v2-dev-ci-pipeline/init.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/traefik-v2-dev-ci-pipeline
CUR_DIR=$(dirname "$SCRIPT")
echo $CUR_DIR

echo "starting containers"
cd $CUR_DIR/traefik
./start-traefik.sh
cd $CUR_DIR



