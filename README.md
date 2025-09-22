# MySQL Quickstart

Pre-built MySQL data directories for instant container startup. Start your MySQL containers in around 2 seconds instead of around 10 seconds by skipping the initialization process.

This library provides a pre-initialized MySQL data directory that eliminates the time-consuming setup phase when starting MySQL containers. The version scheme follows MySQL versions (x.y.z) with an additional build number, so version 8.4.6.0 contains a pre-built MySQL 8.4.6 database.

## Maven/Gradle Coordinates

**Maven:**
```xml
<dependency>
    <groupId>io.github.ag-libs.mysql-quickstart</groupId>
    <artifactId>mysql-quickstart</artifactId>
    <version>8.4.6.0</version>
    <scope>test</scope>
</dependency>
```

**Gradle:**
```gradle
testImplementation 'io.github.ag-libs.mysql-quickstart:mysql-quickstart:8.4.6.0'
```

## Testcontainers Usage (Java)

For Java integration tests using Testcontainers:

```java
new MySQLContainer<>("mysql:8.4.6")
    .withUsername("admin")
    .withPassword("test")
    .withTmpFs(Map.of("/var/lib/mysql", "rw,size=1g"))
    .withCreateContainerCmdModifier(
        cmd -> cmd.withEntrypoint("/mysql-quickstart-entrypoint.sh"))
    .withCopyFileToContainer(
        MountableFile.forClasspathResource(
            "mysql-quickstart/mysql-quickstart-entrypoint.sh", 755),
        "/mysql-quickstart-entrypoint.sh")
    .withClasspathResourceMapping(
        "mysql-quickstart/empty-mysql.tar.gz", "/tmp/empty-mysql.tar.gz", BindMode.READ_ONLY);
```

## Command Line Usage

```bash
# Extract files from JAR
jar -xf mysql-quickstart-8.4.6.0.jar

# Run MySQL container with quickstart
docker run -d \
  --name mysql-quickstart \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=test \
  --tmpfs /var/lib/mysql:rw,size=1g \
  -v $(pwd)/mysql-quickstart/mysql-quickstart-entrypoint.sh:/mysql-quickstart-entrypoint.sh:ro \
  -v $(pwd)/mysql-quickstart/empty-mysql.tar.gz:/tmp/empty-mysql.tar.gz:ro \
  mysql:8.4.6 /mysql-quickstart-entrypoint.sh
```

## Pre-configured Database

The pre-built MySQL database includes:

- **Root user**: `root` with password `test`
- **Admin user**: `admin` with password `test` (full privileges)
- **Test database**: `test` database pre-created
- **Character set**: `utf8mb4` with `utf8mb4_unicode_ci` collation

## License

Licensed under the Apache License 2.0.
