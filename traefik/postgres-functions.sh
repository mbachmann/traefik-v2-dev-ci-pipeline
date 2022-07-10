#!/bin/bash

#  sudo nano /etc/postgresql/12/main/pg_hba.conf
#  set peer to md5 for
#  local   all             postgres                                md5
#  local   all             all                                     md5

function setPsqlPassword () {
  rootpassword="$1"
  sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${rootpassword}';"
  unset rootpassword
}

function initPsqlDatabase() {
   sudo -u postgres psql -t -A -F"," <<'EOF'
\q
exit
EOF
}

# This function works after setting password to postgres user
function createPsqlUserAndDatabase () {
   rootpassword="$1"
   username="$2"
   psqlpassword="$3"
   database="$4"
   PGPASSWORD=${rootpassword}  psql -U postgres -c  "create user ${username} with encrypted password '${psqlpassword}'";
   PGPASSWORD=${rootpassword}  psql -U postgres -c  "create database ${database};"
   PGPASSWORD=${rootpassword}  psql -U postgres -c  "grant all privileges on database ${database} to ${username};"
   unset rootpassword
   unset username
   unset psqlpassword
   unset database
}
