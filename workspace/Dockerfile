#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# To edit the 'workspace' base Image, visit its repository on Github
#    https://github.com/Laradock/workspace
#
# To change its version, see the available Tags on the Docker Hub:
#    https://hub.docker.com/r/laradock/workspace/tags/
#
# Note: Base Image name format {image-tag}-{php-version}
#

ARG PHP_VERSION

# FROM laradock/workspace:2.2-${PHP_VERSION}
FROM letsdockerize/laradock-workspace:2.4-${PHP_VERSION}

ARG PHP_VERSION

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# Start as root
USER root

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    groupadd -g ${PGID} ingenious && \
    useradd -u ${PUID} -g ingenious -m ingenious -G docker_env && \
    usermod -p "*" ingenious -s /bin/bash && \
    apt-get install -yqq \
      apt-utils \
      #
      #--------------------------------------------------------------------------
      # Mandatory Software's Installation
      #--------------------------------------------------------------------------
      #
      # Mandatory Software's such as ("php-cli", "git", "vim", ....) are
      # installed on the base image 'ingenious/workspace' image. If you want
      # to add more Software's or remove existing one, you need to edit the
      # base image (https://github.com/Laradock/workspace).
      #
      # next lines are here becase there is no auto build on dockerhub see https://github.com/ingenious/ingenious/pull/1903#issuecomment-463142846
      libzip-dev zip unzip \
      # Install the zip extension
      php${PHP_VERSION}-zip \
      # nasm
      nasm && \
      php -m | grep -q 'zip'

RUN apt-get install -yqq software-properties-common
RUN add-apt-repository -y ppa:ondrej/php  > /dev/null 2>&1
RUN apt-get update -yqq
RUN apt-get install -yqq build-essential libtool autoconf uuid-dev pkg-config git mc libsodium-dev
RUN apt-get install -yqq php${PHP_VERSION}-dev

###########################################################################
# Set Timezone
###########################################################################

ARG TZ=UTC
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

###########################################################################
# User Aliases
###########################################################################

USER root

COPY ./aliases.sh /root/aliases.sh
COPY ./aliases.sh /home/ingenious/aliases.sh

RUN sed -i 's/\r//' /root/aliases.sh && \
    sed -i 's/\r//' /home/ingenious/aliases.sh && \
    chown ingenious:ingenious /home/ingenious/aliases.sh && \
    echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/aliases.sh" >> ~/.bashrc && \
	echo "" >> ~/.bashrc

USER ingenious

RUN echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/aliases.sh" >> ~/.bashrc && \
	echo "" >> ~/.bashrc

###########################################################################
# Composer:
###########################################################################

USER root

# Add the composer.json
COPY ./composer.json /home/ingenious/.composer/composer.json

# Make sure that ~/.composer belongs to ingenious
RUN chown -R ingenious:ingenious /home/ingenious/.composer

USER ingenious

# Check if global install need to be ran
ARG COMPOSER_GLOBAL_INSTALL=false
ENV COMPOSER_GLOBAL_INSTALL ${COMPOSER_GLOBAL_INSTALL}

RUN if [ ${COMPOSER_GLOBAL_INSTALL} = true ]; then \
    # run the install
    composer global install \
;fi

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="~/.composer/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# Non-root user : PHPUnit path
###########################################################################

# add ./vendor/bin to non-root user's bashrc (needed for phpunit)
USER ingenious

RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="/var/www/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# Crontab
###########################################################################
USER root
COPY ./crontab /etc/cron.d
RUN chmod -R 644 /etc/cron.d
###########################################################################
# SSH2:
###########################################################################
USER root
RUN apt-get install -yqq libssh2-1-dev php${PHP_VERSION}-ssh2
###########################################################################
# PHP V8JS:
###########################################################################
#USER root
#RUN set -xe; \
#    add-apt-repository -y ppa:pinepain/libv8-archived \
#    && apt-get update -yqq \
#    && apt-get install -yqq libv8-5.4 && \
#    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
#      pecl install v8js-0.6.4; \
#    else \
#      pecl install v8js; \
#    fi \
#    && echo "extension=v8js.so" >> /etc/php/${PHP_VERSION}/mods-available/v8js.ini \
#    && phpenmod -s cli v8js \
#    && php -m | grep -q 'v8js'
###########################################################################
# Libpng16 EXTENSION
###########################################################################
RUN apt-get update -yqq && apt-get install -yqq libpng16-16
###########################################################################
# GMP:
###########################################################################
USER root
RUN apt-get install -yqq php${PHP_VERSION}-gmp
###########################################################################
# SOAP:
###########################################################################
USER root
RUN apt-get install -yqq libxml2-dev php${PHP_VERSION}-soap
###########################################################################
# XSL:
###########################################################################
USER root
RUN apt-get install -yqq libxslt-dev php${PHP_VERSION}-xsl
###########################################################################
# LDAP:
###########################################################################
USER root
RUN apt-get install -yqq libldap2-dev && \
    apt-get install -yqq php${PHP_VERSION}-ldap
###########################################################################
# IMAP:
###########################################################################
USER root
RUN apt-get install -yqq php${PHP_VERSION}-imap
###########################################################################
# ssh:
###########################################################################
USER root
COPY insecure_id_rsa /tmp/id_rsa
COPY insecure_id_rsa.pub /tmp/id_rsa.pub
RUN rm -f /etc/service/sshd/down && \
    cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys \
        && cat /tmp/id_rsa.pub >> /root/.ssh/id_rsa.pub \
        && cat /tmp/id_rsa >> /root/.ssh/id_rsa \
        && rm -f /tmp/id_rsa* \
        && chmod 644 /root/.ssh/authorized_keys /root/.ssh/id_rsa.pub \
    && chmod 400 /root/.ssh/id_rsa \
    && cp -rf /root/.ssh /home/ingenious \
    && chown -R ingenious:ingenious /home/ingenious/.ssh
###########################################################################
# MongoDB:
###########################################################################
USER root
RUN pecl install mongodb && \
    echo "extension=mongodb.so" >> /etc/php/${PHP_VERSION}/mods-available/mongodb.ini && \
    ln -s /etc/php/${PHP_VERSION}/mods-available/mongodb.ini /etc/php/${PHP_VERSION}/cli/conf.d/30-mongodb.ini
###########################################################################
# PHP REDIS EXTENSION
###########################################################################
USER root
RUN apt-get install -yqq php-redis
###########################################################################
# PHP ZMQ:
###########################################################################
USER root
RUN set -xe; apt-get update -yqq \
    && apt-get install -yqq php-zmq \
    && echo "extension=zmq.so" >> /etc/php/${PHP_VERSION}/mods-available/zmq.ini \
    && phpenmod -s cli zmq \
    && php -m | grep -q 'zmq'

###########################################################################
# Node / NVM:
###########################################################################
USER ingenious
# Check if NVM needs to be installed
ARG NODE_VERSION=node
ENV NODE_VERSION ${NODE_VERSION}
ENV NVM_DIR /home/ingenious/.nvm

RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash \
        && . $NVM_DIR/nvm.sh \
        && nvm install ${NODE_VERSION} \
        && nvm use ${NODE_VERSION} \
        && nvm alias ${NODE_VERSION} \
        && npm install -g gulp \
        && npm install -g bower \
        && npm install -g @vue/cli \
        && ln -s `npm bin --global` /home/ingenious/.node-bin

# Wouldn't execute when added to the RUN statement in the above block
# Source NVM when loading bash since ~/.profile isn't loaded on non-login shell
RUN echo "" > ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc

# Add NVM binaries to root's .bashrc
USER root

RUN echo "" > ~/.bashrc && \
    echo 'export NVM_DIR="/home/ingenious/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc

# Add PATH for node
ENV PATH $PATH:/home/ingenious/.node-bin

# Make it so the node modules can be executed with 'docker-compose exec'
# We'll create symbolic links into '/usr/local/bin'.
RUN find $NVM_DIR -type f -name node -exec ln -s {} /usr/local/bin/node \; && \
    NODE_MODS_DIR="$NVM_DIR/versions/node/$(node -v)/lib/node_modules" && \
    ln -s $NODE_MODS_DIR/bower/bin/bower /usr/local/bin/bower && \
    ln -s $NODE_MODS_DIR/gulp/bin/gulp.js /usr/local/bin/gulp && \
    ln -s $NODE_MODS_DIR/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s $NODE_MODS_DIR/npm/bin/npx-cli.js /usr/local/bin/npx && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue /usr/local/bin/vue && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue-init /usr/local/bin/vue-init && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue-list /usr/local/bin/vue-list
RUN bash ~/.bashrc

###########################################################################
# YARN:
###########################################################################

USER ingenious

ARG YARN_VERSION=latest
ENV YARN_VERSION ${YARN_VERSION}

RUN [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    if [ ${YARN_VERSION} = "latest" ]; then \
        curl -o- -L https://yarnpkg.com/install.sh | bash; \
    else \
        curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version ${YARN_VERSION}; \
    fi && \
    echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> ~/.bashrc

# Add YARN binaries to root's .bashrc
USER root

RUN echo "" >> ~/.bashrc && \
    echo 'export YARN_DIR="/home/ingenious/.yarn"' >> ~/.bashrc && \
    echo 'export PATH="$YARN_DIR/bin:$PATH"' >> ~/.bashrc

# Add PATH for YARN
ENV PATH $PATH:/home/ingenious/.yarn/bin

###########################################################################
# Laravel Installer:
###########################################################################

USER ingenious
RUN composer global require "laravel/installer"

###########################################################################
# Webpack
###########################################################################

USER ingenious
RUN npm i -g webpack && \
    npm i -g webpack-cli

###########################################################################
# Image optimizers:
###########################################################################

USER root
RUN apt-get install -yqq jpegoptim optipng pngquant gifsicle && \
    exec bash && . ~/.bashrc && \
    npm install -g svgo

USER ingenious

###########################################################################
# PYTHON:
###########################################################################

#USER root
#RUN apt-get -yqq install python python-pip python-dev build-essential  \
#  && python -m pip install --upgrade pip \
#  && python -m pip install --upgrade virtualenv \

###########################################################################
# ImageMagick:
###########################################################################

USER root
RUN apt-get update -yqq && apt-get install -yqq imagemagick php-imagick

###########################################################################
# MySQL Client:
###########################################################################

USER root
RUN apt-get update -yqq && apt-get install -yqq mysql-client


###########################################################################
# GNU Parallel:
###########################################################################

USER root

RUN apt-get update -yqq && apt-get install -yqq parallel


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

# Set default work directory
WORKDIR /var/www