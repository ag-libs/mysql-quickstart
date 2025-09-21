#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Error: MySQL version must be specified as first argument"
    exit 1
fi

MYSQL_VERSION=$1

# Start MySQL container
echo "Starting MySQL container..."
START_TIME=$(date +%s.%N)

CONTAINER_ID=$(docker run -d \
  --tmpfs /var/lib/mysql:rw,size=1g \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=test \
  -v $(pwd)/target/empty-mysql.tar.gz:/tmp/empty-mysql.tar.gz:ro \
  -v $(pwd)/mysql-quickstart-entrypoint.sh:/mysql-quickstart-entrypoint.sh:ro \
  --entrypoint=/mysql-quickstart-entrypoint.sh \
  mysql:$MYSQL_VERSION)

echo "Container ID: $CONTAINER_ID"

# Follow logs in background and wait for MySQL to be ready
echo "Waiting for MySQL to start..."
docker logs -f $CONTAINER_ID &
LOGS_PID=$!

# Wait for MySQL to be ready by checking logs
for i in {1..300}; do
    if docker logs $CONTAINER_ID 2>&1 | grep -q "port: 3306  MySQL Community Server"; then
        END_TIME=$(date +%s.%N)
        STARTUP_TIME=$(echo "$END_TIME - $START_TIME" | bc)
        echo "MySQL is ready! Startup time: ${STARTUP_TIME}s"
        break
    fi
    sleep 0.1
done

# Stop following logs
kill $LOGS_PID 2>/dev/null || true

# Stop container
echo "Stopping container..."
docker kill $CONTAINER_ID >/dev/null
docker rm $CONTAINER_ID >/dev/null

echo "Test completed"
