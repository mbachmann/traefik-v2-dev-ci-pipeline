echo "*** starting wordpress ***"

if [ ! "$(docker ps -q -f name=wordpress)" ]; then
   docker-compose up -d
fi

echo "https://${WORDPRESS_URL}"

echo "https://${DBADMIN_URL}"

