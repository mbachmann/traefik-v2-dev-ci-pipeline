echo "*** starting traefik ***"

chmod 600 acme.json

sed -i "s/MONITOR_URL/$MONITOR_URL/g" traefik_dynamic.toml
sed -i "s/WEBMIN_URL/$WEBMIN_URL/g" traefik_dynamic.toml

if [ ! "$(docker network ls | grep proxy)" ]; then
  echo "Creating proxy network ..."
  docker network create proxy
fi

if [ ! "$(docker network ls | grep localnet)" ]; then
  echo "Creating localnet network ..."
  docker network create localnet
fi

if [ ! "$(docker ps -q -f name=traefik)" ]; then
   docker-compose up -d
fi

echo "https://${MONITOR_URL}"
