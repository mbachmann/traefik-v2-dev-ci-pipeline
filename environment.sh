

export SERVER_NAME="s001"
export SERVER_TYPE="cx11"
export SERVER_IMAGE="ubuntu-20.04"
export SERVER_LOCATION="hel1"
export VOLUME_NAME="${SERVER_NAME}v01"

# Server name is in the base url to allow similar servers and
# lets encrypt allows only 5 registrations with same url within 7 days
export BASE_URL="$SERVER_NAME.thdi.ch"

export MONITOR_URL="monitor.$BASE_URL"
export WORDPRESS_URL="blog.$BASE_URL"
export DBADMIN_URL="db-admin.$BASE_URL"
export TODO_URL="todo.$BASE_URL"
export PORTAINER_URL="portainer.$BASE_URL"
