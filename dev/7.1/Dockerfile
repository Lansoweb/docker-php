FROM leandrosilva/php:7.1

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-url="https://github.com/Lansoweb/docker-php" \
    org.label-schema.vendor="Lansoweb"

# Install XDebug.
RUN pecl install xdebug \
    && echo "zend_extension=\"$(php-config --extension-dir)/xdebug.so\"" > $PHP_INI_DIR/conf.d/xdebug.ini
