FROM debian:bookworm-slim
LABEL maintainer="Zhe Gao<tiantiandas@outlook.com>"

ARG PHP_VERSION=8.2
RUN apt update \
    && apt -y install --no-install-recommends \
       lsb-release apt-transport-https ca-certificates sudo gpg wget git \
       imagemagick nginx openssh-server libarchive-tools \
       python3 python3-pygments\
       php${PHP_VERSION}-fpm \
       php${PHP_VERSION}-mbstring \
       php${PHP_VERSION}-mysql \
       php${PHP_VERSION}-apcu \
       php${PHP_VERSION}-curl \
       php${PHP_VERSION}-gd \
       php${PHP_VERSION}-ldap \
       php${PHP_VERSION}-zip \
       php${PHP_VERSION}-xmlwriter \
       php${PHP_VERSION}-opcache \
    && apt autoremove \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://deb.nodesource.com/setup_lts.x | bash - \
    && apt -y install  --no-install-recommends nodejs \
    && apt autoremove \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd git \
    && usermod -p "*" git \
    && mkdir -p /app \
       /var/run/phabricator \
       /run/sshd \
       /var/log/aphlict \
       /var/tmp/aphlict/pid \
       /data/repos \
    && chown -R www-data:www-data \
       /var/run/phabricator \
       /var/tmp/aphlict/pid/ \
       /var/log/aphlict/ \
    && cd /app \
    && git clone https://we.phorge.it/source/arcanist.git \
    && rm -rf arcanist/.git \
    && git clone https://we.phorge.it/source/phorge.git phabricator \
    && rm -rf phabricator/.git \
    && cd phabricator \
    && npm install ws

COPY assets/ /app/
RUN rm -f /etc/nginx/sites-enabled/* \
    && ln -f /app/config/nginx.app.conf /etc/nginx/sites-enabled/app.conf \
    && rm -f /etc/php/${PHP_VERSION}/fpm/pool.d/* \
    && ln -sf /app/config/php-phabricator.conf /etc/php/${PHP_VERSION}/fpm/pool.d/phabricator.conf \
    && ln -sf /app/config/local.json /app/phabricator/conf/local/local.json \
    && ln -sf /app/config/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini \
    && ln -sf /app/config/sudoer /etc/sudoers.d/

WORKDIR /app/phabricator

EXPOSE 22 80 443
VOLUME [ "/data/", "/app/config", "/app/phabricator/conf/local"]
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["start"]
