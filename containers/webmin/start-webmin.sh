echo "*** starting webmin ***"

if [ ! "$(docker ps -q -f name=webmin)" ]; then
   docker-compose -f ./docker-compose.yml up -d
fi

echo "https://${WEBMIN_URL}"

