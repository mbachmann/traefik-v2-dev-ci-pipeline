echo "*** prepare local databases ***"

databasedir="${CONTAINER_PERSISTENT_VOLUME}/database"

isMysqlInit="${PRJ_ROOT_DIR}"/local/database-records/mysqlinit
isPostgresInit="${PRJ_ROOT_DIR}"/local/database-records/postgresinit

# ============== prepare mysql (binding, root password, firewall) ================

if [[ ! -f "$isMysqlInit" ]]; then
    echo "$isMysqlInit  not exists."
    mysql_root_password=ubuntu
    echo "set mysql binding to 0.0.0.0 and set root password"
    sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
    mysqladmin --user=root --password=pwd password \""${mysql_root_password}"\"
    echo "set firewall rules for mysql"
    sudo ufw allow from 172.16.0.0/12 to any port 3306
    sudo ufw allow from 10.0.0.0/24 to any port 3306
    sudo systemctl restart mysql
    unset mysql_root_password
    touch "${isMysqlInit}"
fi

# ============== mysql link to external volume ================
if [ "${USE_VOLUME}" == "true" ]; then
  mysqldir="${databasedir}/mysql"
  if [ ! -d "$mysqldir" ]; then
    echo "Set the datadir to $databasedir"
    sudo systemctl stop mysql
    sudo rsync -av /var/lib/mysql "${databasedir}"
    sudo mv /var/lib/mysql /var/lib/mysql.bak
    sudo sed -i "s|/var/lib/mysql|${mysqldir}|" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s|# datadir|datadir|" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i -e '$aalias /var/lib/mysql/ -> '"${mysqldir}"'/,' /etc/apparmor.d/tunables/alias
    sudo systemctl restart apparmor
    sudo rm -Rf /var/lib/mysql.bak
    sudo systemctl start mysql
  else
    echo "link data_directory to exisiting database files in ${databasedir}/mysql"
    sudo systemctl stop mysql
    sudo sed -i "s|/var/lib/mysql|${mysqldir}|" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s|# datadir|datadir|" /etc/mysql/mysql.conf.d/mysqld.cnf
    if  [[ $(sudo grep -L   ${mysqldir} /etc/apparmor.d/tunables/alias) ]]  ; then
      echo "add: alias /var/lib/mysql/ -> ${mysqldir} to /etc/apparmor.d/tunables/alias"
      sudo sed -i -e '$aalias /var/lib/mysql/ -> '"${mysqldir}"'/,' /etc/apparmor.d/tunables/alias
      sudo systemctl restart apparmor
    fi
    sudo systemctl start mysql
  fi
  unset mysqldir
fi

# ============== prepare postgres (binding, root password, firewall, create database ubuntu) ================

postgresversion=$(locate bin/postgres | tr -dc '0-9') ; echo $postgresversion

if [[ ! -f "$isPostgresInit" ]]; then
    echo "$isPostgresInit  not exists."

    postgres_root_password=postgres
    echo "set psql binding to 0.0.0.0 and set root password"
    echo "check with: netstat -nlt"
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
    sudo sed -i "s/peer/md5/" /etc/postgresql/12/main/pg_hba.conf
    setPsqlPassword "${postgres_root_password}"
    sudo service postgresql restart
    echo "create ubuntu user and ubuntu database"
    createPsqlUserAndDatabase "${postgres_root_password}" ubuntu ubuntu ubuntu
    echo "set firewall rules for postgres"
    sudo ufw allow from 172.16.0.0/12 to any port 5432
    sudo ufw allow from 10.0.0.0/24 to any port 5432
    unset postgres_root_password
    touch "${isPostgresInit}"
fi


# ============== postgres link to external volume ================
if [ "${USE_VOLUME}" == "true" ]; then
  postgresdir="${databasedir}/postgresql"
  if [ ! -d "$postgresdir" ]; then
    echo "Set the data_directory to $databasedir"
    sudo systemctl stop postgresql
    sudo rsync -av /var/lib/postgresql "${databasedir}"
    sudo mv /var/lib/postgresql/12/main /var/lib/postgresql/12/main.bak
    sudo sed -i "s#data_directory = '/var/lib/postgresql/12/main'#data_directory = '${postgresdir}/12/main'#" /etc/postgresql/12/main/postgresql.conf
    sudo rm -Rf /var/lib/postgresql/12/main.bak
    sudo systemctl start postgresql
  else
    echo "link data_directory to exisiting database files in ${databasedir}/postgresql"
    sudo systemctl stop postgresql
    sudo sed -i "s#data_directory = '/var/lib/postgresql/12/main'#data_directory = '${postgresdir}/12/main'#" /etc/postgresql/12/main/postgresql.conf
    sudo systemctl start postgresql
  fi
  unset postgresdir
fi

unset databasedir
unset isMysqlInit
unset isPostgresInit
