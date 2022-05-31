echo "*** starting wordpress ***"

if [ ! "$(docker ps -q -f name=wordpress)" ]; then
   docker-compose up -d
fi

echo "https://${BLOG_URL}"

echo "https://${DBADMIN_URL}"

