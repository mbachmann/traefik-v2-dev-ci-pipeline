

if [[  -z "${HCLOUD_TOKEN}" ]]; then
  if [[  -f ./scripts/environment.sh ]]; then
    source ./scripts/environment.sh
  else
    source ./environment.sh
  fi
fi

function getZones () {
   ## Get Zones
   # Returns all zones associated with the user.
   curl "https://dns.hetzner.com/api/v1/zones" \
        -k -H "Auth-API-Token: ${DNS_TOKEN}" |  json_pretty

}

function getAllRecords () {
  ## Get Records
  # Returns all records associated with user.
  curl "https://dns.hetzner.com/api/v1/records?zone_id=${ZONE_ID}" \
       -k -H "Auth-API-Token: ${DNS_TOKEN}" | json_pretty
}

function getIp () {
  hcloud server ip "${SERVER_NAME}"
}

function json_pretty () {
  grep -Eo '"[^"]*" *(: *([0-9]*|"[^"]*")[^{}\["]*|,)?|[^"\]\[\}\{]*|\{|\},?|\[|\],?|[0-9 ]*,?' | awk '{if ($0 ~ /^[}\]]/ ) offset-=4; printf "%*c%s\n", offset, " ", $0; if ($0 ~ /^[{\[]/) offset+=4}'
}

function getZone () {
  ## Get Zone
  # Returns an object containing all information about a zone. Zone to get is identified by 'ZoneID'.
  curl "https://dns.hetzner.com/api/v1/zones/${ZONE_ID}" \
        -s -k -H "Auth-API-Token: ${DNS_TOKEN}" \
       -H 'Content-Type: application/json; charset=utf-8' | json_pretty
}

function addDnsRecord () {

  CREATE_SERVICE_NAME=$1

  if [ -z "${CREATE_SERVICE_NAME}" ] ; then
    echo "add one argument for a service name!"
    return 1
  fi

  CREATE_IPV4=$(hcloud server ip "${SERVER_NAME}")

  if [ -z "${CREATE_IPV4}" ] ; then
    echo "Server with name ${SERVER_NAME} not found!"
    return 1
  fi

  if [ -z "${ZONE_ID}" ] ; then
    echo "ZONE_ID ${ZONE_ID} not set!"
    return 1
  fi

  if [ "$(getZone  | grep 'zone not found')" ]; then
    echo "** zoneId ${ZONE_ID} for ${DOMAIN_URL} not found! **"
    echo "check https://dns.hetzner.com/ and navigate to the desired zone"
    echo "extract the zoneId from the url in the browser and copy it to ZONE_ID in environment.sh"
    return 1
  fi

  RECORD_FILE_NAME="${LOCAL_DNS_DIR}/${CREATE_SERVICE_NAME}.${DOMAIN_URL}.json"
  # echo $RECORD_FILE_NAME
  if  test -f "${RECORD_FILE_NAME}" ; then
       echo "${RECORD_FILE_NAME} exists."
       echo "Delete the record with command deleteRecord ${CREATE_SERVICE_NAME}"
       echo "... or delete the file ${RECORD_FILE_NAME} and the record entry in https://dns.hetzner.com/ for the domain ${DOMAIN_URL} manually!"
  fi

  echo "creating record ${CREATE_SERVICE_NAME} for ${DOMAIN_URL} with zoneId: ${ZONE_ID} for ip: ${CREATE_IPV4}"
  ## Create Record
  # Creates a new record.
  CREATE_RESPONSE=$(curl -X "POST" "https://dns.hetzner.com/api/v1/records" \
       -H 'Content-Type: application/json' \
       -k -s -H "Auth-API-Token: ${DNS_TOKEN}" \
       -d $'{
    "value": "'"${CREATE_IPV4}"'",
    "ttl": 86400,
    "type": "A",
    "name": "'"${CREATE_SERVICE_NAME}"'",
    "zone_id": "'"${ZONE_ID}"'"
  }')
  # echo ${CREATE_RESPONSE} | json_pretty

  CREATE_RECORD_ID=$(extractJsonValue "${CREATE_RESPONSE}"  "${CREATE_SERVICE_NAME}")
  echo "The record id for https://${CREATE_SERVICE_NAME}.${DOMAIN_URL} is ${CREATE_RECORD_ID} "
  echo "The record is written to file ${RECORD_FILE_NAME}"
  touch "${RECORD_FILE_NAME}"
  echo "${CREATE_RECORD_ID}" > "${RECORD_FILE_NAME}"

}

function deleteDnsRecord () {

  DELETE_SERVICE_NAME=$1

  if [ -z "${DELETE_SERVICE_NAME}" ] ; then
    echo "add one argument for a service name!"
    return 1
  fi


  DELETE_RECORD_FILE_NAME="${LOCAL_DNS_DIR}/${DELETE_SERVICE_NAME}.${DOMAIN_URL}.json"

  if ! test -f "${DELETE_RECORD_FILE_NAME}" ; then
     echo "${DELETE_RECORD_FILE_NAME} does not exists, cannot delete."
     return 1
  fi
  DELETE_RECORD_ID=$(cat "${DELETE_RECORD_FILE_NAME}")

  ## Delete Record
  echo "delete ${DELETE_RECORD_ID} from api."
  curl -X "DELETE" "https://dns.hetzner.com/api/v1/records/${DELETE_RECORD_ID}" \
      -k -s -H "Auth-API-Token: ${DNS_TOKEN}" # | json_pretty

  echo "remove dns record file ${RECORD_FILE_NAME}."
  rm  "${DELETE_RECORD_FILE_NAME}"

}

function extractJsonValue () {

    JSON_STRING=$1
    JSON_ATTRIBUTE=$2

     if [ -z "${JSON_STRING}" ] ; then
        echo "pass a json String and an attribute to parse!"
        echo "extractJsonValue jsonString jsonAttribute"
        return 1
     fi

     if [ -z "${JSON_ATTRIBUTE}" ] ; then
        echo "pass a json attribute!"
        echo "extractJsonValue jsonString jsonAttribute"
        return 1
     fi

     echo   ${JSON_STRING}  | grep -Eo '"id"[^,]*' | grep -Eo '[^:]*$' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed -e 's/^"//' -e 's/"$//'
}


export JSON_EXAMPLE='{
                    "record": {
                    "type": "A",
                    "id": "string1",
                    "created": "2022-05-20T08:49:33Z",
                    "modified": "2022-05-20T08:49:33Z",
                    "zone_id": "string2",
                    "name": "string3",
                    "value": "string4",
                    "ttl": 0
                    }
                    }'