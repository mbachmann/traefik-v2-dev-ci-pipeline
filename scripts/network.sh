

function createNetworkAndAttachServer () {
  if [ ! "$(hcloud network list | grep ${HCLOUD_NETWORK_NAME})" ]; then
     echo "create network ${HCLOUD_NETWORK_NAME}"
     hcloud network create --name "${HCLOUD_NETWORK_NAME}" --ip-range 10.0.0.0/24
     # eu-central includes hel1,fsn1 and nbg1
     hcloud network add-subnet "${HCLOUD_NETWORK_NAME}" --network-zone eu-central --type server --ip-range 10.0.0.0/24
  fi

  echo "Attach server ${SERVER_NAME} to network ${HCLOUD_NETWORK_NAME} with ip ${PRIVATE_IPV4} (public ip: ${IPV4})"
  hcloud server attach-to-network "${SERVER_NAME}" --network "${HCLOUD_NETWORK_NAME}" --ip "${PRIVATE_IPV4}"
}
