echo "*** starting jenkins ***"

if [[ ! "$(docker images -q jenkins:jenkins-master 2> /dev/null)" == "" ]]; then
  echo "Build docker image for jenkins:jenkins-master"
  cd ./docker || exit
  docker build -t jenkins:jenkins-master .
  cd ..
fi

if [ ! -d "${CONTAINER_PERSISTENT_VOLUME}/secrets" ]; then
  mkdir "${CONTAINER_PERSISTENT_VOLUME}/secrets"
  echo "Creating secrets in ${CONTAINER_PERSISTENT_VOLUME}/secrets"
fi

if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/jenkins_admin_id.txt" ]] ; then
    echo "admin" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/jenkins_admin_id.txt"
fi
if [[ ! -f "${CONTAINER_PERSISTENT_VOLUME}/secrets/jenkins_admin_password.txt" ]] ; then
    echo "admin" > "${CONTAINER_PERSISTENT_VOLUME}/secrets/jenkins_admin_password.txt"
fi

if [ ! "$(docker ps -q -f name=jenkins-master)" ]; then
   docker-compose up -d
fi

echo "https://${JENKINS_URL}"

