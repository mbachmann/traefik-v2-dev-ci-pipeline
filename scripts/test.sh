# Absolute path to this script, e.g. /home/user/traefik-v2-dev-ci-pipeline/scripts/environment.sh
SCRIPTDIR=$(readlink -f "$0")

if [[ ! "${SCRIPTDIR}" == *"traefik-v2-dev-ci-pipeline"* ]]; then
   export CUR_SCRIPTDIR=$PWD/scripts;
else
  # Absolute path this script is in, thus /home/user/traefik-v2-dev-ci-pipeline/scripts
  export CUR_SCRIPTDIR=$(dirname "$SCRIPTDIR")
fi


echo $CUR_SCRIPTDIR
export PRJ_ROOT_DIR="$(dirname "$CUR_SCRIPTDIR")"
echo $PRJ_ROOT_DIR

export LOCAL_DIR="${PRJ_ROOT_DIR}/local"
echo $LOCAL_DIR
HCLOUD_TOKEN=$(cat "${LOCAL_DIR}/hcloud-token.local")
export HCLOUD_PROJECT_NAME="cas-oop"
echo "${HCLOUD_TOKEN}"

if command -v hcloud &> /dev/null
then
  if [ ! "$(hcloud context list | grep ${HCLOUD_PROJECT_NAME})" ]; then
     echo "Creating the context ${HCLOUD_PROJECT_NAME}"
     echo "${HCLOUD_TOKEN}" | hcloud context create "${HCLOUD_PROJECT_NAME}"
  fi
fi