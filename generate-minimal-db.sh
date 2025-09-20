#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <mysql-version>"
    echo "Example: $0 8.4"
    exit 1
fi

MYSQL_VERSION="$1"
dir="$(git rev-parse --show-toplevel)/target"
mkdir -p "${dir}"

function cleanup {
  if [ -n "${id}" ]; then
    echo "Stopping container..."
    docker rm -f "${id}"
  fi
}

trap cleanup EXIT

echo "Creating MySQL ${MYSQL_VERSION} container..."
id=$(docker run -d \
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=test \
  -e MYSQL_ROOT_PASSWORD=test \
  mysql:${MYSQL_VERSION} \
  mysqld \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_unicode_ci \
  --explicit_defaults_for_timestamp \
  --sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES,ONLY_FULL_GROUP_BY,ERROR_FOR_DIVISION_BY_ZERO,NO_ZERO_DATE,NO_ZERO_IN_DATE)

sleep 1

echo "Waiting for container to start..."
for i in {1..60}
do
  if bash -c "docker logs ${id} 2>&1 | grep -q 'port: 3306  MySQL Community Server'"; then
    echo "Container started."

    echo "Flushing MySQL tables for consistent data copy..."
    docker exec "${id}" mysql -u root -ptest -e "FLUSH TABLES WITH READ LOCK;"

    echo "Creating compressed archive while MySQL is locked..."
    docker exec "${id}" tar cf /data.tar -C /var/lib/mysql .

    echo "Copying archive..."
    docker cp "${id}":/data.tar "${dir}/empty-mysql.tar"

    echo "Done"
    exit 0
  fi
  echo "Waiting ${i}/60..."
  sleep 1
done

echo "Container failed to start!"
docker logs "${id}"
exit 1
