

source ./extract-ip.sh
ssh -i ~/.key/hetzner ubuntu@$IPV4 <<'ENDSSH'
  whoami
ENDSSH