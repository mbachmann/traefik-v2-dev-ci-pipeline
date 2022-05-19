echo "*** starting wordpress ***"

if [ ! "$(docker ps -q -f name=wordpress)" ]; then
   docker-compose up -d
fi

echo "https://blog.s001.thdi.ch"
echo "https://${WORDPRESS_URL}"

echo "https://db-admin.s001.thdi.ch"
echo "https://${DBADMIN_URL}"

