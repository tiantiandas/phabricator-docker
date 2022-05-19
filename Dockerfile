FROM debian:buster-slim
LABEL maintainer="Zhe Gao<me@zhegao.me>"

RUN apt update \
    && apt -y install --no-install-recommends \
       lsb-release apt-transport-https ca-certificates sudo gpg wget git \
       imagemagick nginx openssh-server php7.3-fpm php7.3-mbstring \
       php7.3-mysql php7.3-apcu php7.3-curl php7.3-gd php7.3-ldap php7.3-zip \
       php7.3-xmlwriter php7.3-opcache python-pip libarchive-tools\
    && apt autoremove \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://deb.nodesource.com/setup_lts.x | bash - \
    && apt -y install  --no-install-recommends nodejs \
    && apt autoremove \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install Pygments

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
    && git clone https://github.com/phacility/arcanist.git \
    && rm -rf arcanist/.git \
    && git clone https://github.com/phacility/phabricator.git \
    && rm -rf phabricator/.git \
    && cd phabricator \
    && npm install ws

COPY assets/ /app/
RUN rm -f /etc/nginx/sites-enabled/* /etc/nginx/nginx.conf \
    && ln -f /app/config/nginx.conf /etc/nginx/nginx.conf \
    && rm -f /etc/php/7.3/fpm/pool.d/* \
    && ln -sf /app/config/php-phabricator.conf /etc/php/7.3/fpm/pool.d/phabricator.conf \
    && ln -sf /app/config/local.json /app/phabricator/conf/local/local.json \
    && ln -sf /app/config/php.ini /etc/php/7.3/fpm/php.ini \
    && ln -sf /app/config/sudoer /etc/sudoers.d/

WORKDIR /app/phabricator

EXPOSE 22 80 443
VOLUME [ "/data/", "/app/config", "/app/phabricator/conf/local"]
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["start"]
