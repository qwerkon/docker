#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# To edit the 'php-fpm' base Image, visit its repository on Github
#    https://github.com/Laradock/php-fpm
#
# To change its version, see the available Tags on the Docker Hub:
#    https://hub.docker.com/r/laradock/php-fpm/tags/
#
# Note: Base Image name format {image-tag}-{php-version}
#

ARG PHP_VERSION

# FROM laradock/php-fpm:2.2-${PHP_VERSION}
FROM php:${PHP_VERSION}-fpm

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    apt-get install -yqqqq \
      apt-utils \
      libzip-dev zip unzip wget && \
      docker-php-ext-configure zip --with-libzip && \
      # Install the zip extension
      docker-php-ext-install zip && \
      php -m | grep -q 'zip'

###########################################################################
# SSH2:
###########################################################################

ARG INSTALL_SSH2=false

RUN apt-get -y install libssh2-1-dev && \
    pecl install -a ssh2-1.1.2 && \
    docker-php-ext-enable ssh2

USER root
RUN rm /etc/apt/preferences.d/no-debian-php && \
    apt-get -y install libxml2-dev php-soap && \
    docker-php-ext-install soap

###########################################################################
# XSL:
###########################################################################

RUN apt-get -y install libxslt-dev && \
    docker-php-ext-install xsl


###########################################################################
# MongoDB:
###########################################################################

RUN pecl install mongodb && docker-php-ext-enable mongodb

###########################################################################
# bcmath:
###########################################################################
RUN docker-php-ext-install bcmath
###########################################################################
# GMP (GNU Multiple Precision):
###########################################################################

RUN apt-get install -yqq libgmp-dev && docker-php-ext-install gmp

###########################################################################
# PHP Memcached:
###########################################################################

#RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
#    && mkdir -p memcached \
#    && tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
#    && ( \
#        cd memcached \
#        && phpize \
#        && ./configure \
#        && make -j$(nproc) \
#        && make install \
#    ) \
#    && rm -r memcached \
#    && rm /tmp/memcached.tar.gz \
#    && docker-php-ext-enable memcached

###########################################################################
# Exif:
###########################################################################
RUN docker-php-ext-install exif
###########################################################################
# Opcache:
###########################################################################

RUN docker-php-ext-install opcache

# Copy opcache configration
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

###########################################################################
# Mysqli Modifications:
###########################################################################
RUN docker-php-ext-install mysqli


###########################################################################
# Human Language and Character Encoding Support:
###########################################################################

RUN apt-get install -yqq zlib1g-dev libicu-dev g++ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl

###########################################################################
# Image optimizers:
###########################################################################
USER root
RUN apt-get install -yqq jpegoptim optipng pngquant gifsicle

###########################################################################
# ImageMagick:
###########################################################################

USER root

RUN apt-get install -yqq libmagickwand-dev imagemagick && \
    pecl install imagick && \
    docker-php-ext-enable imagick

###########################################################################
# IMAP:
###########################################################################
RUN apt-get install -yqq libc-client-dev libkrb5-dev && \
    rm -r /var/lib/apt/lists/* && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

###########################################################################
# Calendar:
###########################################################################

USER root
RUN docker-php-ext-configure calendar && \
    docker-php-ext-install calendar

###########################################################################
# APCU:
###########################################################################

RUN pecl install apcu \
    && pecl install apcu_bc \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

###########################################################################
# YAML:
###########################################################################

USER root
RUN apt-get update -yqq && apt-get install libyaml-dev -yqq \
    && pecl install yaml \
    && docker-php-ext-enable yaml

###########################################################################
# Install additional locales:
###########################################################################

ARG ADDITIONAL_LOCALES

RUN apt-get install -yqq locales \
    && echo '' >> /usr/share/locale/locale.alias \
    && temp="${ADDITIONAL_LOCALES%\"}" \
    && temp="${temp#\"}" \
    && for i in ${temp}; do sed -i "/$i/s/^#//g" /etc/locale.gen; done \
    && locale-gen

###########################################################################
# MySQL Client:
###########################################################################

USER root
RUN apt-get update -yqq && apt-get -y install mysql-client

###########################################################################
# ZMQ:
###########################################################################

USER root
RUN apt-get -yqq update && \
	apt-get install -yqq libzmq3-dev && \
	pecl install zmq-beta && \
    docker-php-ext-enable zmq

###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

RUN usermod -u 1000 www-data

WORKDIR /var/www

ADD install_composer.sh ./install_composer.sh
RUN ./install_composer.sh && rm ./install_composer.sh

ARG PHP_UPSTREAM_CONTAINER=php-fpm
ARG PHP_UPSTREAM_PORT=9000

CMD ["php-fpm"]

EXPOSE ${PHP_UPSTREAM_PORT}
