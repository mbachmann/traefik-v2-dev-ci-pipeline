#!/bin/bash

if [[  -z "${SERVER_NAME}" ]]; then
  echo "load environment.sh in extract-ip.sh"
  if [[  -f ./scripts/environment.sh ]]; then
    source ./scripts/environment.sh
  else
    source ./environment.sh
  fi
fi

if [ "$(hcloud server list | grep ${SERVER_NAME})" ]; then
   export IPV4=$(hcloud server ip "${SERVER_NAME}")
fi
# echo "The IP is $IPV4"

