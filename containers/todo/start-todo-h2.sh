echo "*** starting todo h2 ***"

if [ ! "$(docker ps -q -f name=todoh2)" ]; then
   docker-compose -f ./docker-compose-h2-traefik-v2.yml up -d
fi

echo "https://${TODO_H2_URL}"

