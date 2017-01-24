FROM php:7.0.15-cli

MAINTAINER Leandro Silva <leandro@leandrosilva.info>

COPY build/apt-install build/docker-php-pecl-install /usr/local/bin/

# Include composer
RUN apt-install \
    git \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libpq-dev \
    zlib1g-dev \
    libicu-dev \
    vim \
    libxml2-dev \
    libaio1 \
    unzip

ENV COMPOSER_HOME /root/composer
ENV PATH vendor/bin:$COMPOSER_HOME/vendor/bin:$PATH
RUN curl -sS https://getcomposer.org/installer | php -- \
      --install-dir=/usr/local/bin \
      --filename=composer
VOLUME /root/composer/cache

COPY build/instantclient-*.zip /tmp/
RUN unzip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /home/ \
    && unzip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /home/ \
    && mv /home/instantclient_12_1 /home/oracle \
    && ln -s /home/oracle/libclntsh.so.12.1 /home/oracle/libclntsh.so \
    && ln -s /home/oracle/libclntshcore.so.12.1 /home/oracle/libclntshcore.so \
    && ln -s /home/oracle/libocci.so.12.1 /home/oracle/libocci.so \
    && rm -rf /tmp/instantclient-*.zip
ENV ORACLE_HOME /home/oracle

# Install useful extensions
RUN docker-php-ext-install \
    opcache \
    bcmath \
    ctype \
    dom \
    fileinfo \
    gettext \
    intl \
    json \
    mbstring \
    mcrypt \
    mysqli \
    pcntl \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    phar \
    simplexml \
    zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-configure oci8 --with-oci8=instantclient,/home/oracle \
    && docker-php-ext-install oci8

RUN pecl install apcu-5.1.3 \
    && pecl install apcu_bc-1.0.3 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

RUN printf '[Date]\ndate.timezone=UTC' > /usr/local/etc/php/conf.d/timezone.ini \
    && echo "phar.readonly = off" > /usr/local/etc/php/conf.d/phar.ini

# Setup the Xdebug version to install
ENV XDEBUG_VERSION 2.5.0
ENV XDEBUG_MD5 0d31602a6ee2ba6d2e18a6db79bdb9a2a706bcd9

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

