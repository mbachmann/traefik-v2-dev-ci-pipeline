#!/bin/bash

if [[  -z "${IPV4}" ]]; then
    echo "load extract-ip.sh in run-script-remote.sh"
  if [[  -f ./scripts/extract-ip.sh ]]; then
    source ./scripts/extract-ip.sh
  else
    source ./extract-ip.sh
  fi
fi

function remoteWhoAmI () {
  echo "whoami"
  ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ./local/id_rsa ubuntu@"$IPV4" << 'ENDSSH'
    whoami
ENDSSH
}

function login () {
  ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ./local/id_rsa ubuntu@"$IPV4"
}