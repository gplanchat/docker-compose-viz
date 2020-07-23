DCV_IMAGE_NAME=pmsipilot/docker-compose-viz

COMPOSER ?= composer
COMPOSERFLAGS ?=
DOCKER ?= docker
PHP ?= php

.PHONY: clean docker test unit cs fix-cs

docker: docker.lock

test: vendor unit cs

unit: vendor
	$(PHP) bin/kahlan --pattern='*.php' --reporter=verbose --persistent=false --cc=true

cs:
	$(PHP) bin/php-cs-fixer fix --dry-run

fix-cs:
	$(PHP) bin/php-cs-fixer fix

clean:
	rm -rf vendor/

docker.lock: Dockerfile bin/entrypoint.sh vendor src/application.php src/functions.php
	#$(COMPOSER) dump-autoload --classmap-authoritative
	$(DOCKER) build -t $(DCV_IMAGE_NAME) .
	touch docker.lock

ifndef COMPOSERFLAGS
vendor: composer.lock
	$(COMPOSER) install --prefer-dist
else
vendor: composer.lock
	$(COMPOSER) update $(COMPOSERFLAGS)
endif

composer.lock: composer.json
	$(COMPOSER) update $(COMPOSERFLAGS)
