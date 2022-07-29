echo "*** starting wordpress ***"

if [ ! -d "${CONTAINER_PERSISTENT_VOLUME}/secrets" ]; then
  mkdir "${CONTAINER_PERSISTENT_VOLUME}/secrets"
  echo "Creating secrets in ${CONTAINER_PERSISTENT_VOLUME}/secrets"
fi

if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/wordpress_db_password.txt" ]] ; then
    echo -n "wordpress" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/wordpress_db_password.txt"
fi
if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/wordpress_db_root_password.txt" ]] ; then
    echo -n "wordpress" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/wordpress_db_root_password.txt"
fi

if [ ! "$(docker ps -q -f name=phpmyadmin)" ]; then
   docker-compose -f docker-compose-db-tools.yml up -d
fi


echo "https://${DBADMIN_URL}"

echo "https://${DB_PHP_MYADMIN_URL}"
