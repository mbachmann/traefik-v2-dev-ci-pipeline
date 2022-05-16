echo "*** starting traefik ***"

chmod 600 acme.json

if [ ! "$(docker network ls | grep proxy)" ]; then
  echo "Creating proxy network ..."
  docker network create proxy
fi

if [ ! "$(docker ps -q -f name=traefik)" ]; then
   docker-compose up -d
fi

echo "https://monitor.thdi.ch"
