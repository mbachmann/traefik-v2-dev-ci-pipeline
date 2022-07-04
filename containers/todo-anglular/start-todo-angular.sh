echo "*** starting todo anguar ***"

if [ ! "$(docker ps -q -f name=todo-angular)" ]; then
   docker-compose -f ./docker-compose.yml up -d
fi

echo "https://${TODO_ANGULAR_URL}"

