FROM php:7.1-fpm

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-url="https://github.com/Lansoweb/docker-php" \
    org.label-schema.vendor="Lansoweb"

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
        libbz2-dev \
        libmemcached-dev \
        libmysqlclient-dev \
        libsasl2-dev \
    " \
    runtimeDeps=" \
        curl \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libmcrypt4 \
        libmcrypt-dev \
        libmemcachedutil2 \
        libpng12-dev \
        libpq-dev \
        libxml2-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install bcmath bz2 calendar fileinfo gettext iconv intl json mbstring mcrypt mysqli pcntl opcache pdo_mysql pdo_pgsql pgsql soap simplexml zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && pecl install apcu memcached mongodb redis \
    && docker-php-ext-enable apcu.so memcached.so mongodb.so redis.so \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/*

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer
ENV COMPOSER_HOME /root/composer \
    COMPOSER_ALLOW_SUPERUSER=1 \
    PATH $PATH:/root/composer/vendor/bin

