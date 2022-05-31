

source cli
echo "login to ubuntu@$IPV4"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ./local/id_rsa ubuntu@"$IPV4"

