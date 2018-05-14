FROM leandrosilva/php:7.2-apache

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-url="https://github.com/Lansoweb/docker-php" \
    org.label-schema.vendor="Lansoweb"

COPY config/dev.ini /usr/local/etc/php/conf.d/env.ini

# Install XDebug.
RUN pecl install xdebug \
    && echo "zend_extension=\"$(php-config --extension-dir)/xdebug.so\"" > $PHP_INI_DIR/conf.d/xdebug.ini
