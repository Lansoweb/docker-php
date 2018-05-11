ARG VERSION=latest
FROM php:${VERSION}

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-url="https://github.com/Lansoweb/docker-php" \
    org.label-schema.vendor="Lansoweb"

ENV COMPOSER_HOME=/root/composer \
    COMPOSER_ALLOW_SUPERUSER=1 \
    PATH=$COMPOSER_HOME/vendor/bin:$PATH
ADD install.sh /tmp/install.sh
RUN bash /tmp/install.sh $PHP_VERSION \
    && rm /tmp/install.sh
