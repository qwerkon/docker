ARG MYSQL_VERSION=5.7
FROM mysql:${MYSQL_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get install -y --no-install-recommends apt-utils && apt-get install -y expect

ARG TZ=UTC
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && chown -R mysql:root /var/lib/mysql/

COPY my.cnf /etc/mysql/conf.d/my.cnf
#COPY mysql_secure.sh /tmp/mysql_secure.sh
#RUN ./tmp/mysql_secure.sh ${NEW_MYSQL_PASSWORD}

EXPOSE 3306/tcp
CMD ["mysqld"]