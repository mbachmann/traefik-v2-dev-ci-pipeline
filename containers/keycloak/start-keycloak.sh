echo "*** starting keycloak ***"

if [ ! -d "${CONTAINER_PERSISTENT_VOLUME}/secrets" ]; then
  mkdir "${CONTAINER_PERSISTENT_VOLUME}/secrets"
  echo "Creating secrets in ${CONTAINER_PERSISTENT_VOLUME}/secrets"
fi

if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/keycloak_db_password.txt" ]] ; then
    echo "keycloak" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/keycloak_db_password.txt"
fi

if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/keycloak_db_root_password.txt" ]] ; then
    echo "keycloak" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/keycloak_db_root_password.txt"
fi

if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/keycloak_user.txt" ]] ; then
    echo "admin" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/keycloak_user.txt"
fi

if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/keycloak_password.txt" ]] ; then
    echo "keycloak" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/keycloak_password.txt"
fi

if [ ! "$(docker ps -q -f name=keycloak)" ]; then
   docker-compose up -d
fi

echo "https://${KEYCLOAK_ADMINER_URL}"

echo "https://${KEYCLOAK_URL}"