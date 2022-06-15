echo "*** starting nexus ***"

if [ ! -d "${CONTAINER_PERSISTENT_VOLUME}/nexus" ]; then
  mkdir "${CONTAINER_PERSISTENT_VOLUME}/nexus"
  echo "Creating folder for nexus in ${CONTAINER_PERSISTENT_VOLUME}/nexus"
fi


if [ ! "$(docker ps -q -f name=nexus)" ]; then
   docker-compose -f ./docker-compose.yml up -d
fi

echo "https://${NEXUS_URL}"
echo "https://${NEXUS_REGISTRY_URL}"

