#!/bin/bash
if [ ! -f /var/lib/mysql/mysql/user.frm ]; then
  tar -xf /tmp/empty-mysql.tar -C /var/lib/mysql/
  chown -R mysql:mysql /var/lib/mysql/
fi
exec docker-entrypoint.sh "$@"
