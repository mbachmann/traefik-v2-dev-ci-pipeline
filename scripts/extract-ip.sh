#!/bin/bash

if [[  -f ./scripts/environment.sh ]]; then
  source ./scripts/environment.sh
else
  source ./environment.sh
fi

export IPV4=$(hcloud server ip "${SERVER_NAME}")
# echo "The IP is $IPV4"
