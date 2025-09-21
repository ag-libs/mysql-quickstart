#!/bin/bash
if [ ! -f /var/lib/mysql/mysql/user.frm ]; then
  tar -xzf /tmp/empty-mysql.tar.gz -C /var/lib/mysql/
  chown -R mysql:mysql /var/lib/mysql/
fi
exec docker-entrypoint.sh mysqld \
  --innodb-buffer-pool-size=16M \
  --skip-performance-schema \
  --skip-log-bin \
  --skip-mysqlx
