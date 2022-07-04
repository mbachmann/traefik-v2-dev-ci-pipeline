echo "*** prepare webmin ***"

if ! grep -Fxq "referers=${WEBMIN_URL}" /etc/webmin/config
then
 echo "*** add  referers=${WEBMIN_URL} to file /etc/webmin/config ***"
 echo "referers=${WEBMIN_URL}" | sudo tee -a /etc/webmin/config
fi

if ! grep -Fxq "redirect_host=${WEBMIN_URL}" /etc/webmin/miniserv.conf
then
 echo "*** add  redirect_host=${WEBMIN_URL} to file /etc/webmin/miniserv.conf ***"
 echo "redirect_host=${WEBMIN_URL}" | sudo tee -a /etc/webmin/miniserv.conf
 echo "*** add  redirect_port=80 to file /etc/webmin/miniserv.conf ***"
 echo "redirect_port=80" | sudo tee -a /etc/webmin/miniserv.conf
 echo "*** change ssl=1 to ssl=0 in file /etc/webmin/miniserv.conf ***"
 sudo sed -i "s/ssl=1/ssl=0/" /etc/webmin/miniserv.conf
 echo "*** restart webmin ***"
 sudo /etc/webmin/restart
 # Open firewall to webmin service on localhost for containers
 sudo ufw  allow  from 172.16.0.0/12 to any port 10000

fi

# echo "*** starting webmin redirect container ***"

# if [ ! "$(docker ps -q -f name=webmin)" ]; then
   # docker-compose -f ./docker-compose.yml up -d
# fi

echo "https://${WEBMIN_URL}"

