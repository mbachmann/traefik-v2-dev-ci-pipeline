#!/bin/bash

if [[  -f ./scripts/environment.sh ]]; then
  source ./scripts/environment.sh
else
  source ./environment.sh
fi

if [[  -f ./scripts/create-ssh-key.sh ]]; then
  source ./scripts/create-ssh-key.sh
else
  source ./create-ssh-key.sh
fi

if [[  -f ./scripts/extract-ip.sh ]]; then
  source ./scripts/extract-ip.sh
else
  source ./extract-ip.sh
fi

if [[  -f ./scripts/dns.sh ]]; then
  source ./scripts/dns.sh
else
  source ./dns.sh
fi

if [[  -f ./scripts/run-script-remote.sh ]]; then
  source ./scripts/run-script-remote.sh
else
  source ./run-script-remote.sh
fi

if [[  -f ./scripts/volume.sh ]]; then
  source ./scripts/volume.sh
else
  source ./volume.sh
fi

if [[  -f ./scripts/commands.sh ]]; then
  source ./scripts/commands.sh
else
  source ./commands.sh
fi



