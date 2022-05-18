#!/bin/bash



# Absolute path to this script, e.g. /home/user/traefik-v2-dev-ci-pipeline/init-container.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/traefik-v2-dev-ci-pipeline
CUR_DIR=$(dirname "$SCRIPT")
echo $CUR_DIR

# make all .sh files executable
find $CUR_DIR -type f -iname "*.sh" -exec chmod +x {} \;

echo "starting containers"
cd $CUR_DIR/traefik
./start-traefik.sh
cd $CUR_DIR



