set -e

MYSQL_DATA_DIR="/var/lib/mysql"
MYSQL_DATABASE_DIR="${MYSQL_DATA_DIR}/mysql"

if [ ! -d $MYSQL_DATABASE_DIR ]; then
  mysql_install_db
  cp /etc/my.cnf ${MYSQL_DATA_DIR}/my.cnf.template
  chown -R mysql:mysql /var/lib/mysql
fi

mysqld_safe &

set +e
for i in `seq 1 20`;
do
  mysqladmin ping
  if [ $? -eq 0 ]; then
    break
  fi
  sleep 1
done
set -e

mysql -e "GRANT ALL PRIVILEGES ON *.* TO root@'%' WITH GRANT OPTION"

wait
