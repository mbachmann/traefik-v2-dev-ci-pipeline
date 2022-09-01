#!/bin/bash

echo "** configure-localhost-mysql-database **"
source ${PRJ_ROOT_DIR}/server/mysql-functions.sh

databasedir="${CONTAINER_PERSISTENT_VOLUME}/database"
echo "databasedir = ${databasedir}"
isMysqlInit="${PRJ_ROOT_DIR}"/local/database-records/mysqlinit

# ============== prepare mysql (binding, root password, firewall) ================

if [[ ! -f "$isMysqlInit" ]]; then
    echo "$isMysqlInit  not exists."
    mysql_root_password=ubuntu
    sudo systemctl stop mysql
    echo "set mysql binding to 0.0.0.0, mysql users to % and set root password"
    sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo systemctl start mysql
    # sudo systemctl status mysql
    mysqladmin --user=root --password=pwd password "${mysql_root_password}"
    # SELECT host, user FROM mysql.user;
    # update mysql.user set host='%' where host='localhost';
    mysql -u root -p"${mysql_root_password}" -e "update mysql.user set host='%' where host='localhost';"
    echo "set firewall rules for mysql"
    sudo ufw allow from 172.16.0.0/12 to any port 3306
    sudo ufw allow from 10.0.0.0/24 to any port 3306
    sudo ufw allow from 192.168.0.0/16 to any port 3306
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


unset databasedir
unset isMysqlInit


