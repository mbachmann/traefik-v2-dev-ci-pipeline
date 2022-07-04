#!/bin/bash

function createFirewall()  {
    echo Creates a firewall
    FIREWALL_FILE_NAME="${LOCAL_FIREWALL_DIR}/firewall.json"
    CREATE_RESPONSE=$(curl -X "POST" "https://api.hetzner.cloud/v1/firewalls" \
         -H 'Content-Type: application/json' \
         -k -s -H "Authorization: Bearer ${HCLOUD_TOKEN}" \
         -d $'{
           "name": "'"${FIREWALL_NAME}"'",
           "rules": [
               {
                 "description": "Allow port 22 - ssh",
                 "direction": "in",
                 "port": "22",
                 "protocol": "tcp",
                 "source_ips": [
                   "0.0.0.0/0",
                   "::/0"
                 ]
               },
               {
                 "description": "Allow port 80 - http",
                 "direction": "in",
                 "port": "80",
                 "protocol": "tcp",
                 "source_ips": [
                   "0.0.0.0/0",
                   "::/0"
                 ]
               },
               {
                 "description": "Allow port 443 - https",
                 "direction": "in",
                 "port": "443",
                 "protocol": "tcp",
                 "source_ips": [
                   "0.0.0.0/0",
                   "::/0"
                 ]
               },
               {
                 "description": "Allow port 4242 - edu java",
                 "direction": "in",
                 "port": "4242",
                 "protocol": "tcp",
                 "source_ips": [
                   "0.0.0.0/0",
                   "::/0"
                 ]
               },
               {
                 "description": "Allow port 9998 -  edu java",
                 "direction": "in",
                 "port": "9998",
                 "protocol": "tcp",
                 "source_ips": [
                   "0.0.0.0/0",
                   "::/0"
                 ]
               },
               {
                 "description": "Allow port 9999 -  edu java",
                 "direction": "in",
                 "port": "9999",
                 "protocol": "tcp",
                 "source_ips": [
                   "0.0.0.0/0",
                   "::/0"
                 ]
               }
             ]
           }')
    # echo $CREATE_RESPONSE
    if [[ ! $CREATE_RESPONSE == *'"error": null'* ]]; then
       echo "cannot create firewall - firewall already exists"
       return 1
    fi
    CREATE_RECORD_IDS=$(extractJsonValue "${CREATE_RESPONSE}"  firewall)
    CREATE_RECORD_ID=`echo "${CREATE_RECORD_IDS}" | head -1`
    echo "The record id for the firewall is ${CREATE_RECORD_ID} "
    echo "The record id is written to file ${FIREWALL_FILE_NAME}"
    touch "${FIREWALL_FILE_NAME}"
    echo "${CREATE_RECORD_ID}" > "${FIREWALL_FILE_NAME}"
}
