#!/bin/bash

if [ "${USE_VOLUME}" == "true" ]; then

  sudo systemctl stop docker.service
  sudo systemctl stop docker.socket

  dockerdir="${CONTAINER_PERSISTENT_VOLUME}/docker"

  if  [[ $(sudo grep -L   ${dockerdir} /lib/systemd/system/docker.service) ]]  ; then
    echo "move docker: replace   ExecStart=/usr/bin/dockerd with ExecStart=/usr/bin/dockerd -g ${dockerdir}"
    sudo sed -i "s|ExecStart=/usr/bin/dockerd|ExecStart=/usr/bin/dockerd -g ${dockerdir}|" /lib/systemd/system/docker.service
  fi

  if [ ! -d "$dockerdir" ]; then
      echo "move docker:  /var/lib/docker/ to ${dockerdir} ***"
      sudo mkdir -p "${dockerdir}"
      sudo rsync -aqxP /var/lib/docker/ "${dockerdir}"
  fi

  sudo systemctl daemon-reload
  sudo systemctl start docker

  ps aux | grep -i docker | grep -v grep

  # delete all containers
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)

  unset dockerdir
fi
