#!/bin/bash

echo "configure-localhost-postgres-database"
source "${PRJ_ROOT_DIR}/server/postgres-functions.sh"

databasedir="${CONTAINER_PERSISTENT_VOLUME}/database"
echo "databasedir = ${databasedir}"
isPostgresInit="${PRJ_ROOT_DIR}"/local/database-records/postgresinit


# ============== prepare postgres (binding, root password, firewall, create database ubuntu) ================

postgresversion=$(locate bin/postgres | tr -dc '0-9') ; echo "postgres version is $postgresversion"

if [[ ! -f "$isPostgresInit" ]]; then
    echo "$isPostgresInit  not exists."

    postgres_root_password=postgres
    echo "postgres: set psql binding to 0.0.0.0 and set root password"
    echo "postgres: check with: netstat -nlt"
    setPsqlPassword "${postgres_root_password}"
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
    sudo sed -i "s/peer/md5/" /etc/postgresql/12/main/pg_hba.conf
    # host    all             all             10.0.0.0/24             md5
    # host    all             all             172.0.0.0/12            md5
    echo 'hostnossl    all          all            0.0.0.0/0  trust' >> /etc/postgresql/12/main/pg_hba.conf
    sudo service postgresql restart
    sudo systemctl status postgresql
    echo "postgres: create ubuntu user and ubuntu database"
    createPsqlUserAndDatabase "${postgres_root_password}" ubuntu ubuntu ubuntu
    echo "postgres: set firewall rules for postgres"
    sudo ufw allow from 172.16.0.0/12 to any port 5432
    sudo ufw allow from 10.0.0.0/24 to any port 5432
    sudo ufw allow from 192.168.0.0/16 to any port 5432
    unset postgres_root_password
    touch "${isPostgresInit}"
fi


# ============== postgres link to external volume ================
if [ "${USE_VOLUME}" == "true" ]; then
  postgresdir="${databasedir}/postgresql"
  if [ ! -d "$postgresdir" ]; then
    echo "postgres: Set the data_directory to $databasedir"
    sudo systemctl stop postgresql
    sudo systemctl status postgresql
    sudo rsync -av /var/lib/postgresql "${databasedir}"
    sudo mv /var/lib/postgresql/12/main /var/lib/postgresql/12/main.bak
    sudo sed -i "s#data_directory = '/var/lib/postgresql/12/main'#data_directory = '${postgresdir}/12/main'#" /etc/postgresql/12/main/postgresql.conf
    sudo rm -Rf /var/lib/postgresql/12/main.bak
    sudo systemctl start postgresql
  else
    echo "postgres: link data_directory to exisiting database files in ${databasedir}/postgresql"
    sudo systemctl stop postgresql
    sudo systemctl status postgresql
    sudo sed -i "s#data_directory = '/var/lib/postgresql/12/main'#data_directory = '${postgresdir}/12/main'#" /etc/postgresql/12/main/postgresql.conf
    sudo systemctl start postgresql
  fi
  unset postgresdir
fi

unset databasedir
unset isPostgresInit

