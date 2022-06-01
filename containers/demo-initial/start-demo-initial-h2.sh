echo "*** starting todo h2 ***"

if [ ! "$(docker ps -q -f name=demoinitial)" ]; then
   docker-compose -f ./docker-compose-h2-traefik-v2.yml up -d
fi

echo "https://${DEMO_INITIAL_URL}"

