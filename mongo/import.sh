#!/usr/bin/env bash

MONGO_DATABASE_NAME="${1}"
MONGO_LOGIN="${2}"
MONGO_PASSWD="${3}"

cd /docker-entrypoint-initdb.d/
tar xzf common.tar.gz

cd /docker-entrypoint-initdb.d/common

ls -1 *.json | sed 's/.json$//' | while read col; do
    mongoimport --type json --authenticationDatabase admin --username $MONGO_LOGIN --password $MONGO_PASSWD --jsonArray --db $MONGO_DATABASE_NAME --collection $col < $col.json;
done

cd ../

rmdir -Rf /docker-entrypoint-initdb.d/common
rm common.tar.gz