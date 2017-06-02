FROM php:7.1.5-fpm-alpine

MAINTAINER Leandro Silva <leandro@leandrosilva.info>

RUN echo '#!/bin/sh' > /usr/local/bin/apk-install \
    && echo 'apk add --update "$@" && rm -rf /var/cache/apk/*' >> /usr/local/bin/apk-install \
    && chmod +x /usr/local/bin/apk-install

RUN echo 'http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk update \
    && apk-install \
    git \
    zlib-dev \
    freetype-dev \
    jpeg-dev \
    libjpeg-turbo-dev \
    postgresql-dev \
    libmcrypt-dev \
    libpng-dev \
    icu-dev \
    vim \
    libxml2-dev \
    freetype-dev \
    unzip \
    libc6-compat \
    openssl \
    gcc \
    autoconf \
    libintl \
    gettext-dev \
    pcre-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

# Install useful extensions
RUN docker-php-ext-install \
    opcache \
    bcmath \
    ctype \
    dom \
    fileinfo \
    gd \
    gettext \
    intl \
    json \
    mcrypt \
    mysqli \
    pcntl \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    phar \
    simplexml \
    zip

RUN set -xe \
    && apk-install \
    g++ \
    make \
    && pecl install apcu-5.1.8 \
    && pecl install apcu_bc-1.0.3 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

RUN pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis

RUN printf '[Date]\ndate.timezone=UTC' > /usr/local/etc/php/conf.d/timezone.ini \
    && echo "phar.readonly = off" > /usr/local/etc/php/conf.d/phar.ini

# Setup the Xdebug version to install
ENV XDEBUG_VERSION 2.5.4
ENV XDEBUG_MD5 300ca6fc3d95025148b0b5d0c96e14e54299e536a93a5d68c67b2cf32c9432b8

# Install Xdebug
RUN set -x \
    && curl -SL "http://xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz" -o xdebug.tgz \
    && echo "$XDEBUG_MD5  xdebug.tgz" | shasum -c - \
    && mkdir -p /usr/src/xdebug \
    && tar -xf xdebug.tgz -C /usr/src/xdebug --strip-components=1 \
    && rm xdebug.* \
    && cd /usr/src/xdebug \
    && phpize \
    && ./configure \
    && make -j"$(nproc)" \
    && make install \
    && make clean

# Include composer
ENV COMPOSER_HOME /root/composer
ENV PATH vendor/bin:$COMPOSER_HOME/vendor/bin:$PATH
RUN curl -sS https://getcomposer.org/installer | php -- \
      --install-dir=/usr/local/bin \
      --filename=composer
VOLUME /root/composer/cache
