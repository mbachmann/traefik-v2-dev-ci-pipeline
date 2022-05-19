#!/bin/bash

if [[  -f ./scripts/extract-ip.sh ]]; then
  source ./scripts/extract-ip.sh
else
  source ./extract-ip.sh
fi

ssh -i ~/.key/hetzner ubuntu@$IPV4 <<'ENDSSH'
  whoami
ENDSSH