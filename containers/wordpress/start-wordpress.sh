echo "*** starting wordpress ***"

if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/db_password.txt" ]] ; then
    echo "wordpress" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/db_password.txt"
fi
if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/db_root_password.txt" ]] ; then
    echo "wordpress" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/db_password.txt"
fi

if [ ! "$(docker ps -q -f name=wordpress)" ]; then
   docker-compose up -d
fi

echo "https://${BLOG_URL}"

echo "https://${DBADMIN_URL}"

echo "https://${DB_PHP_MYADMIN_URL}"
