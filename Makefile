SHELL := /bin/bash
.PHONY: pull build-nopull build test

IMAGE := leandrosilva/php
VERSION ?= latest
PHP_VERSION := $(firstword $(subst -, ,$(VERSION)))

# Extensions.
EXTENSIONS := \
	bcmath \
	bz2 \
	calendar \
	iconv \
	intl \
	gd \
	mbstring \
	memcached \
	mysqli \
	pdo_mysql \
	pdo_pgsql \
	pgsql \
	redis \
	soap \
	zip

build:
	@echo " =====> Building $(IMAGE):$(VERSION)..."
	@docker build --quiet \
		--build-arg VERSION=$(VERSION) \
		--label org.label-schema.build-date=$(shell date -u "+%Y-%m-%dT%H:%M:%SZ") \
		--label org.label-schema.vcs-ref=$(shell git rev-parse HEAD) \
		--tag $(IMAGE):$(VERSION) \
		.

test:
	@echo -e "=====> Testing loaded extensions... \c"
	@if [[ -z `docker images $(IMAGE) | grep "\s$(VERSION)\s"` ]]; then \
		echo 'FAIL [Missing image!!!]'; \
		exit 1; \
	fi
	@modules=`docker run --rm $(IMAGE):$(VERSION) php -m`; \
	for ext in $(EXTENSIONS); do \
		if [[ "$${modules}" != *"$${ext}"* ]]; then \
			echo "FAIL [$${ext}]"; \
			exit 1; \
		fi \
	done
	@if [[ "$(VERSION)" == *'-apache' ]]; then \
		apache=`docker run --rm $(IMAGE):$(VERSION) apache2ctl -M 2> /dev/null`; \
		if [[ "$${apache}" != *'rewrite_module'* ]]; then \
			echo 'FAIL [mod_rewrite]'; \
			exit 1; \
		fi \
	fi
	@if [[ -z `docker run --rm $(IMAGE):$(VERSION) composer --version 2> /dev/null | grep '^Composer version [0-9][0-9]*\.[0-9][0-9]*'` ]]; then \
		echo 'FAIL [Composer]'; \
		exit 1; \
	fi
	@echo 'OK'
