#!/bin/bash

if [[  -f ./scripts/environment.sh ]]; then
  source ./scripts/environment.sh
else
  source ./environment.sh
fi

export IPV4=$(hcloud server describe "${SERVER_NAME}"| grep IP: | grep \\. |  sed  -e 's/^.*://' | sed -e 's/^[[:space:]]*//')
# echo "The IP is $IPV4"
