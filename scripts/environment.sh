#!/bin/bash

# All details in https://developers.hetzner.com/cloud/

# Project name as defined in https://console.hetzner.cloud/projects
# Lists know contexts on the local machine: hcloud context list
export HCLOUD_PROJECT_NAME="cas-oop"
# Arbitrary user name
export HCLOUD_USER_NAME="mbach"
# Arbitrary server name
export SERVER_NAME="s005"
# Server type as in https://www.hetzner.com/cloud
# List server types: hcloud server-type list
export SERVER_TYPE="cx11"
# Server image as in https://console.hetzner.cloud/projects/1414551/servers/create
# List images: hcloud image list
export SERVER_IMAGE="ubuntu-20.04"
# List locations: hcloud location list
export SERVER_LOCATION="hel1"
# Ubuntu user and home directory, **do not change this name**
export UBUNTU_USER=ubuntu
export UBUNTU_HOME="/home/${UBUNTU_USER}"

# During server setup, this repo is cloned -> change it to your repo
export GIT_REPO=https://github.com/mbachmann/traefik-v2-dev-ci-pipeline

# ================================ VOLUMES ========================================
# USE_VOLUME true will create and attach a seperate volume to the server
# The container persitent storage is on the server disc or on the attachted volume
export USE_VOLUME="true"
# The name of the additional volume in Hetzner hcloud portal https://www.hetzner.com/cloud
# List existing volumes: hcloud volume list
export VOLUME_NAME="${SERVER_NAME}v01"
export VOLUME_MOUNT_NAME="storage1"
export CONTAINER_VOLUME_DATA_FOLDER="/mnt/${VOLUME_MOUNT_NAME}"
export CONTAINER_USER_DATA_FOLDER="${UBUNTU_HOME}/data"

# The minimum volume size is 10 GBytes
export VOLUME_SIZE="10"

# Arbitary ssh key name
export SSH_KEY_NAME="${HCLOUD_USER_NAME}"@s001

# ===================================== DNS =========================================
# lets encrypt allows only 5 registrations with same url within 7 days
# If the DNS is managed by Hetzner you can use the automatic DNS reccord adding https://dns.hetzner.com/
export USE_HETZNER_DNS_API="true"
export DOMAIN_URL="sintares.com"
# recover zone id with getzones, defined in dns.sh
export ZONE_ID="aUypFiQLNDVPCUA3GJ8MLJ"

# ===================================== URL's =========================================

# Server name is in the base url to allow several servers for one url and
# In this example, the server name is part of the url
export SUB_DOMAIN=".${SERVER_NAME}"
# export SUB_DOMAIN=""
export BASE_URL="${SERVER_NAME}.${DOMAIN_URL}"

# Service Names
export MONITOR_SVC="monitor${SUB_DOMAIN}"
export BLOG_SVC="blog${SUB_DOMAIN}"
export DBADMIN_SVC="db-admin${SUB_DOMAIN}"
export DB_PHP_MYADMIN_SVC="db-pypmyadmin${SUB_DOMAIN}"
export TODO_H2_SVC="todo-h2${SUB_DOMAIN}"
export DEMO_INITIAL_SVC="demo-initial${SUB_DOMAIN}"
export TODO_MYSQL_SVC="todo-mysql${SUB_DOMAIN}"
export PORTAINER_SVC="portainer${SUB_DOMAIN}"
export PORTAINER_EDGE_SVC="edge${SUB_DOMAIN}"

# URL's for installed applications
export MONITOR_URL="${MONITOR_SVC}.${DOMAIN_URL}"
export BLOG_URL="${BLOG_SVC}.${DOMAIN_URL}"
export DBADMIN_URL="${DBADMIN_SVC}.${DOMAIN_URL}"
export DB_PHP_MYADMIN_URL="${DB_PHP_MYADMIN_SVC}.${DOMAIN_URL}"
export TODO_H2_URL="${TODO_H2_SVC}.${DOMAIN_URL}"
export DEMO_INITIAL_URL="${DEMO_INITIAL_SVC}.${DOMAIN_URL}"
export TODO_MYSQL_URL="${TODO_MYSQL_SVC}.${DOMAIN_URL}"
export PORTAINER_URL="${PORTAINER_SVC}.${DOMAIN_URL}"
export PORTAINER_EDGE_URL="${PORTAINER_EDGE_SVC}.${DOMAIN_URL}"

function createAllDNSRecords() {
  addDnsRecord "${MONITOR_SVC}"
  addDnsRecord "${PORTAINER_SVC}"
  addDnsRecord "${PORTAINER_EDGE_SVC}"
  addDnsRecord "${BLOG_SVC}"
  addDnsRecord "${DBADMIN_SVC}"
  addDnsRecord "${DB_PHP_MYADMIN_SVC}"
  addDnsRecord "${TODO_H2_SVC}"
  addDnsRecord "${DEMO_INITIAL_SVC}"
  addDnsRecord "${TODO_MYSQL_SVC}"
}

function deleteAllDNSRecords() {
  deleteDnsRecord "${MONITOR_SVC}"
  deleteDnsRecord "${PORTAINER_SVC}"
  deleteDnsRecord "${PORTAINER_EDGE_SVC}"
  deleteDnsRecord "${BLOG_SVC}"
  deleteDnsRecord "${DBADMIN_SVC}"
  deleteDnsRecord "${DB_PHP_MYADMIN_SVC}"
  deleteDnsRecord "${TODO_H2_SVC}"
  deleteDnsRecord "${DEMO_INITIAL_SVC}"
  deleteDnsRecord "${TODO_MYSQL_SVC}"
}

# ==================================== DO NOT CHANGE FROM HERE =========================
if [ "$HOSTNAME" = "$SERVER_NAME" ]; then
  echo "environment.sh is running on linux host $SERVER_NAME"
else
  if ! command -v hcloud &>/dev/null; then
    echo "<hcloud> could not be found. Please install hcloud or restart the console"
  fi
fi

export CUR_SCRIPTDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# Absolute path this script is in, thus /home/user/traefik-v2-dev-ci-pipeline
export PRJ_ROOT_DIR="$(dirname "$CUR_SCRIPTDIR")"
export LOCAL_DIR="$PRJ_ROOT_DIR/local"

export LOCAL_DNS_DIR="${PRJ_ROOT_DIR}/local/dns-records"

if [ ! "$HOSTNAME" = "$SERVER_NAME" ]; then
  export HCLOUD_TOKEN=$(cat "${LOCAL_DIR}/hcloud-token.local")
  export DNS_TOKEN=$(cat "${LOCAL_DIR}/dns-token.local")
fi

if [ "${USE_VOLUME}" == "true" ]; then
  export CONTAINER_PERSISTENT_VOLUME="${CONTAINER_VOLUME_DATA_FOLDER}"
else
  export CONTAINER_PERSISTENT_VOLUME="${CONTAINER_USER_DATA_FOLDER}"
fi

function printEnvironment() {
  echo "Configured Enviroment in environment.sh"
  echo SERVER_NAME="${SERVER_NAME}"
  echo SERVER_TYPE="${SERVER_TYPE}"
  echo SERVER_IMAGE="${SERVER_IMAGE}"
  echo SERVER_LOCATION="${SERVER_LOCATION}"
  echo VOLUME_NAME="${VOLUME_NAME}"
  echo BASE_URL="${BASE_URL}"
  echo PRJ_ROOT_DIR="${PRJ_ROOT_DIR}"
  echo SSH_KEY_NAME="${SSH_KEY_NAME}"
  echo LOCAL_DNS_DIR="${LOCAL_DNS_DIR}"

}
