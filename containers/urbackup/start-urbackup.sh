echo "*** starting urbackup ***"

if [ ! -d "${CONTAINER_PERSISTENT_VOLUME}/urbackup" ]; then
  mkdir "${CONTAINER_PERSISTENT_VOLUME}/urbackup"
  mkdir "${CONTAINER_PERSISTENT_VOLUME}/urbackup/storage"
  mkdir "${CONTAINER_PERSISTENT_VOLUME}/urbackup/data"
  echo "Creating folder for backup in ${CONTAINER_PERSISTENT_VOLUME}/urbackup"
fi


if [ ! "$(docker ps -q -f name=urbackup)" ]; then
   docker-compose -f ./docker-compose.yml up -d
fi

echo "https://${URBACKUP_URL}"

