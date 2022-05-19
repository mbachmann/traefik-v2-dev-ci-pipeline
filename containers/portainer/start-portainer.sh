echo "*** starting portainer ***"

if [ ! "$(docker ps -q -f name=portainer)" ]; then
   docker-compose -f ./docker-compose.yml up -d
fi

echo "https://portainer.s001.thdi.ch"

echo "https://${PORTAINER_URL}"