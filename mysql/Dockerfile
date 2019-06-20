ARG MYSQL_VERSION=5.7
FROM mysql:${MYSQL_VERSION}

ARG TZ=UTC
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && chown -R mysql:root /var/lib/mysql/

COPY my.cnf /etc/mysql/conf.d/my.cnf

#ARG MYSQL_VERSION=root
#COPY mysql_secure.sh /tmp/mysql_secure.sh
#RUN ./tmp/mysql_secure.sh ${MYSQL_VERSION}

CMD ["mysqld"]

EXPOSE 3306
