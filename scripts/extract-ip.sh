#!/bin/bash

if [[  -z "${SERVER_NAME}" ]]; then
  echo "load environment.sh in extract-ip.sh"
  if [[  -f ./scripts/environment.sh ]]; then
    source ./scripts/environment.sh
  else
    source ./environment.sh
  fi
fi

export IPV4=$(hcloud server ip "${SERVER_NAME}")
# echo "The IP is $IPV4"

