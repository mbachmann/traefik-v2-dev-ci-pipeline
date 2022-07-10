echo "*** prepare local databases ***"

databasedir="${CONTAINER_PERSISTENT_VOLUME}/database"
echo "databasedir = ${databasedir}"
isMysqlInit="${PRJ_ROOT_DIR}"/local/database-records/mysqlinit
isPostgresInit="${PRJ_ROOT_DIR}"/local/database-records/postgresinit

# ============== prepare mysql (binding, root password, firewall) ================

if [[ ! -f "$isMysqlInit" ]]; then
    echo "$isMysqlInit  not exists."
    mysql_root_password=ubuntu
    sudo systemctl stop mysql
    sudo systemctl status mysql
    echo "set mysql binding to 0.0.0.0 and set root password"
    sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo systemctl start mysql
    sudo systemctl status mysql
    mysqladmin --user=root --password=pwd password "${mysql_root_password}"
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
    echo "mysql: Set the datadir to $databasedir"
    sudo systemctl stop mysql
    sudo systemctl status mysql
    sudo rsync -av /var/lib/mysql "${databasedir}"
    sudo mv /var/lib/mysql /var/lib/mysql.bak
    sudo sed -i "s|/var/lib/mysql|${mysqldir}|" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s|# datadir|datadir|" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i -e '$aalias /var/lib/mysql/ -> '"${mysqldir}"'/,' /etc/apparmor.d/tunables/alias
    sudo systemctl restart apparmor
    sudo systemctl status apparmor
    sudo rm -Rf /var/lib/mysql.bak
    sudo systemctl start mysql
  else
    echo "mysql: link data_directory to exisiting database files in ${databasedir}/mysql"
    sudo systemctl stop mysql
    sudo sed -i "s|/var/lib/mysql|${mysqldir}|" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s|# datadir|datadir|" /etc/mysql/mysql.conf.d/mysqld.cnf
    if  [[ $(sudo grep -L   ${mysqldir} /etc/apparmor.d/tunables/alias) ]]  ; then
      echo "mysql add: alias /var/lib/mysql/ -> ${mysqldir} to /etc/apparmor.d/tunables/alias"
      sudo sed -i -e '$aalias /var/lib/mysql/ -> '"${mysqldir}"'/,' /etc/apparmor.d/tunables/alias
      sudo systemctl restart apparmor
      sudo systemctl status apparmor
    fi
    sudo systemctl start mysql
  fi
  unset mysqldir
fi

# ============== prepare postgres (binding, root password, firewall, create database ubuntu) ================

postgresversion=$(locate bin/postgres | tr -dc '0-9') ; echo "postgres version is $postgresversion"

if [[ ! -f "$isPostgresInit" ]]; then
    echo "$isPostgresInit  not exists."

    postgres_root_password=postgres
    echo "postgres: set psql binding to 0.0.0.0 and set root password"
    echo "postgres: check with: netstat -nlt"
    sudo systemctl stop postgresql
    sudo systemctl status postgresql
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
    sudo sed -i "s/peer/md5/" /etc/postgresql/12/main/pg_hba.conf
    sudo systemctl start postgresql
    sudo systemctl status postgresql
    setPsqlPassword "${postgres_root_password}"
    sudo service postgresql restart
    sudo systemctl status postgresql
    echo "postgres: create ubuntu user and ubuntu database"
    createPsqlUserAndDatabase "${postgres_root_password}" ubuntu ubuntu ubuntu
    echo "postgres: set firewall rules for postgres"
    sudo ufw allow from 172.16.0.0/12 to any port 5432
    sudo ufw allow from 10.0.0.0/24 to any port 5432
    unset postgres_root_password
    touch "${isPostgresInit}"
fi


# ============== postgres link to external volume ================
if [ "${USE_VOLUME}" == "true" ]; then
  postgresdir="${databasedir}/postgresql"
  if [ ! -d "$postgresdir" ]; then
#    echo "postgres: Set the data_directory to $databasedir"
#    sudo systemctl stop postgresql
#    sudo systemctl status postgresql
#    sudo rsync -av /var/lib/postgresql "${databasedir}"
#    sudo mv /var/lib/postgresql/12/main /var/lib/postgresql/12/main.bak
#    sudo sed -i "s#data_directory = '/var/lib/postgresql/12/main'#data_directory = '${postgresdir}/12/main'#" /etc/postgresql/12/main/postgresql.conf
#    sudo rm -Rf /var/lib/postgresql/12/main.bak
#    sudo systemctl start postgresql
  else
#    echo "postgres: link data_directory to exisiting database files in ${databasedir}/postgresql"
 #   sudo systemctl stop postgresql
#    sudo systemctl status postgresql
#    sudo sed -i "s#data_directory = '/var/lib/postgresql/12/main'#data_directory = '${postgresdir}/12/main'#" /etc/postgresql/12/main/postgresql.conf
#    sudo systemctl start postgresql
  fi
  unset postgresdir
fi

unset databasedir
unset isMysqlInit
unset isPostgresInit

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
