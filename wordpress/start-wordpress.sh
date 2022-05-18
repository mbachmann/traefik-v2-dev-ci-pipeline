echo "*** starting wordpress ***"

if [ ! "$(docker ps -q -f name=wordpress)" ]; then
   docker-compose up -d
fi

echo "https://blog.thdi.ch"
echo "https://db-admin.thdi.ch"

