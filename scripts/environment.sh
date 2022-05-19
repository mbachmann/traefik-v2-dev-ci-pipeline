
# All details in https://developers.hetzner.com/cloud/

# Project name as defined in https://console.hetzner.cloud/projects
# Lists know contexts on the local machine: hcloud context list
export HCLOUD_PROJECT_NAME="cas-oop"
# Arbitrary user name
export HCLOUD_USER_NAME="mbach"
# Arbitrary server name
export SERVER_NAME="s001"
# Server type as in https://www.hetzner.com/cloud
# List server types: hcloud server-type list
export SERVER_TYPE="cx11"
# Server image as in https://console.hetzner.cloud/projects/1414551/servers/create
# List images: hcloud image list
export SERVER_IMAGE="ubuntu-20.04"
# List locations: hcloud location list
export SERVER_LOCATION="hel1"
# List existing volumes: hcloud volume list
export VOLUME_NAME="${SERVER_NAME}v01"
# Arbitary ssh key name
export SSH_KEY_NAME=${HCLOUD_USER_NAME}@${SERVER_NAME}
# Server name is in the base url to allow several servers for one url and
# lets encrypt allows only 5 registrations with same url within 7 days
export BASE_URL="$SERVER_NAME.thdi.ch"
export USE_HETZNER_DNS_API="true"

# URL's for installed applications
export MONITOR_URL="monitor.$BASE_URL"
export WORDPRESS_URL="blog.$BASE_URL"
export DBADMIN_URL="db-admin.$BASE_URL"
export TODO_URL="todo.$BASE_URL"
export PORTAINER_URL="portainer.$BASE_URL"



# ==================== DO NOT CHANGE FROM HERE =========================
if [ hostname == "$SERVER_NAME" ]
then
  echo "script is running on linux host $SERVER_NAME"
else
  if ! command -v hcloud &> /dev/null
  then
    echo "<hcloud> could not be found. Please install hcloud or restart the console"
  fi
fi



# Absolute path to this script, e.g. /home/user/traefik-v2-dev-ci-pipeline/scripts/environment.sh
SCRIPTDIR=$(readlink -f "$0")

if [[ ! "${SCRIPTDIR}" == *"traefik-v2-dev-ci-pipeline"* ]]; then
   export CUR_SCRIPTDIR=$PWD/scripts;
else
  # Absolute path this script is in, thus /home/user/traefik-v2-dev-ci-pipeline/scripts
  CUR_SCRIPTDIR=$(dirname "$SCRIPTDIR")
  if [[ ! "${SCRIPTDIR}" == *"scripts"* ]]; then
    CUR_SCRIPTDIR="${CUR_SCRIPTDIR}/scripts"
  fi
  export CUR_SCRIPTDIR
fi

# Absolute path this script is in, thus /home/user/traefik-v2-dev-ci-pipeline
export PRJ_ROOT_DIR="$(dirname "$CUR_SCRIPTDIR")"
export LOCAL_DIR="$PRJ_ROOT_DIR"/local

LOCAL_DIR="${PRJ_ROOT_DIR}/local"

if [ ! hostname == "$SERVER_NAME" ]
then
  export HCLOUD_TOKEN=$(cat "${LOCAL_DIR}/hcloud-token.local")
  export DNS_TOKEN=$(cat "${LOCAL_DIR}/dns-token.local")
fi



