#!/bin/bash
#

set -e

BASE_DIR=/app/phabricator
DISABLE_STORAGE_UPGRADE=${DISABLE_STORAGE_UPGRADE:-false}

_validate() {
    if [ "$1" != 0 ];then
        echo "Failed to start $2"
        exit 1
    fi
}

initialize() {
    ${BASE_DIR}/bin/storage upgrade --force
    _validate $? upgrade
}

start() {
    if [ "$DISABLE_STORAGE_UPGRADE" != "true" ];then
        initialize
    fi

    ${BASE_DIR}/bin/auth lock 
    /usr/sbin/sshd -f /app/config/sshd_config
    _validate $? SSH
    
    sudo -u www-data ${BASE_DIR}/bin/aphlict start
    _validate $? aphlict
    
    sudo -u git ${BASE_DIR}/bin/phd start
    _validate $? phd
    
    /usr/sbin/php-fpm7.3 -D
    _validate $? php-fpm
    
    /usr/sbin/nginx -t
    _validate $? nginx
    /usr/sbin/nginx -g "daemon off;"
}

$@
