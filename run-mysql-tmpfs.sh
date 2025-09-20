#!/bin/bash
set -e

# Cleanup function to stop container on interrupt
function cleanup {
  echo "Stopping MySQL container..."
  docker ps -q --filter "ancestor=mysql:8.4" --filter "status=running" | xargs -r docker kill
}

trap cleanup EXIT

# Run MySQL with tmpfs
docker run \
  --rm \
  --tmpfs /var/lib/mysql:rw,size=1g \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=test \
  -v $(pwd)/target/empty-mysql.tar:/tmp/empty-mysql.tar:ro \
  -v $(pwd)/init-tmpfs.sh:/usr/local/bin/init-tmpfs.sh:ro \
  --entrypoint=/usr/local/bin/init-tmpfs.sh \
  mysql:8.4 mysqld \
  --innodb-buffer-pool-size=16M \
  --skip-performance-schema \
  --skip-log-bin

echo "MySQL starting with tmpfs. Connect with: mysql -h localhost -u root -ptest"
