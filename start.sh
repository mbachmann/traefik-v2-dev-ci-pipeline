echo "starting containers"
CUR_DIR=$(pwd)
cd $CUR_DIR/traefik
echo "*** starting traefik ***"
docker-compose up -d
echo "https://monitor.thdi.ch"
cd -


