#!/bin/bash

function escape_mysql_quote_string {
    # escape: '
    echo "$1" | sed 's/'\''/'\\\\\''/g'
}

MYSQL_DATABASE=$(escape_mysql_quote_string "$MYSQL_DATABASE")
MYSQL_USER=$(escape_mysql_quote_string "$MYSQL_USER")
MYSQL_PASSWORD=$(escape_mysql_quote_string "$MYSQL_PASSWORD")

echo "Creating solo.init.sql file..."

cat <<EOSQL > /docker-entrypoint-initdb.d/solo.init.sql
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
    CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'localhost';
    FLUSH PRIVILEGES;
EOSQL

rm -rf $(realpath $0)