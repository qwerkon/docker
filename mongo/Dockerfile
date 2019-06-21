FROM mongo:latest
COPY mongo.conf /usr/local/etc/mongo/mongo.conf

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

COPY docker-entrypoint-initdb.d/common.tar.gz /docker-entrypoint-initdb.d/
COPY import.sh /docker-entrypoint-initdb.d/import-json.sh

RUN ./docker-entrypoint-initdb.d/import-json.sh ${MONGO_DATABASE_NAME} ${MONGO_INITDB_ROOT_USERNAME} ${MONGO_INITDB_ROOT_PASSWORD}

EXPOSE 27017
CMD ["mongod"]