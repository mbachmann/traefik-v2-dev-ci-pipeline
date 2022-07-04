echo "*** starting nginx-site ***"

if [[ ! "$(docker images -q nginx:nginx-site 2> /dev/null)" == "" ]]; then
  echo "Build docker image for nginx:nginx-site"
  docker build -t nginx:nginx-site .
fi

if [ ! "$(docker ps -q -f name=nginx-site)" ]; then
   docker-compose up -d
fi

echo "https://${SITE_URL}"

