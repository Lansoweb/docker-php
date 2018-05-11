#!/bin/bash
set -e

if [[ -z "$1" ]]; then
    echo 'Missing PHP version!'
    exit 1
fi
phpVersion="$1"

###########################################################
### List of dependencies and extensions to be installed ###
###########################################################
buildDeps=" \
    libbz2-dev \
    libmemcached-dev \
    libsasl2-dev \
"
runtimeDeps=" \
    curl \
    git \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmemcachedutil2 \
    libpq-dev \
    libxml2-dev \
    unzip \
    vim \
"
pearExtensions=" \
    bcmath \
    bz2 \
    calendar \
    iconv \
    intl \
    mbstring \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    simplexml \
    soap \
    zip \
"
peclExtensions=" \
    apcu \
    memcached \
    mongodb \
    redis \
"

#####################################
### Version-specific adjustements ###
#####################################
if [[ $phpVersion != "7.2."* ]]; then
    # PHP < 7.2
    buildDeps="${buildDeps} libmysqlclient-dev"
    runtimeDeps="${runtimeDeps} libmcrypt4 libmcrypt-dev libpng12-dev"
    pearExtensions="${pearExtensions} mcrypt"
else
    # PHP 7.2
    buildDeps="${buildDeps} default-libmysqlclient-dev"
    runtimeDeps="${runtimeDeps} libpng-dev"
    pearExtensions="${pearExtensions} sodium"
fi

#############
### Debug ###
#############
echo "BUILD DEPENDENCIES   : ${buildDeps}"
echo "RUNTIME DEPENDENCIES : ${runtimeDeps}"
echo "PEAR EXTENSIONS      : ${pearExtensions}"
echo "PECL EXTENSIONS      : ${peclExtensions}"

####################
### APT Packages ###
####################
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps

#######################
### PEAR Extensions ###
#######################
docker-php-ext-install $pearExtensions
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
docker-php-ext-install gd

#######################
### PECL Extensions ###
#######################
pecl install $peclExtensions
docker-php-ext-enable apcu.so memcached.so mongodb.so redis.so

###############
### Cleanup ###
###############
apt-get purge -y --auto-remove $buildDeps
rm -r /var/lib/apt/lists/*

##########################
### Apache mod_rewrite ###
##########################
if [[ `command -v a2enmod` ]]; then
    a2enmod rewrite
fi

################
### Composer ###
################
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
