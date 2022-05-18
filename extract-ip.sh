#!/bin/bash

source ./environment.sh
export IPV4=$(hcloud server describe $SERVER_NAME | grep IP: | grep \\. |  sed  -e 's/^.*://' | sed -e 's/^[[:space:]]*//')
# echo "The IP is $IPV4"
