.PHONY: start stop graceful restart install-% restart-% docker-%

%-hp1           : MOJO_MODE = stage
%-hp1           : SSH_OPTIONS =
%-hp1           : RSYNC_OPTIONS =
%-beta1 %-beta2 : MOJO_MODE = beta
%-beta1 %-beta2 : SSH_OPTIONS =
%-beta1 %-beta2 : RSYNC_OPTIONS =
%-app1  %-app2  : MOJO_MODE = production
%-app1  %-app2  : SSH_OPTIONS =
%-app1  %-app2  : RSYNC_OPTIONS =

install-% restart-% : CONFIG = mimir.$(MOJO_MODE).conf

%-hp1   : TARGET = mimir-hp
%-beta1 : TARGET = mimir1.beta
%-beta2 : TARGET = mimir2.beta
%-app1  : TARGET = mimir1.app
%-app2  : TARGET = mimir2.app

%-hp1   : USER = mimir-app
%-beta1 : USER = mimir-app
%-beta2 : USER = mimir-app
%-app1  : USER = mimir-app
%-app2  : USER = mimir-app

vendor: cpanfile cpanfile.snapshot
	carton install && carton bundle
	@touch vendor

SOURCES = Makefile cpanfile cpanfile.snapshot $(CONFIG) \
	lib script public templates vendor

install-%: vendor
	rsync -avHS $(RSYNC_OPTIONS) -- $(SOURCES) $(USER)@$(TARGET):mimir/
	ssh $(TARGET) $(SSH_OPTIONS) -l $(USER) "cd mimir && carton install --cached --without develop; if [ ! -e log ]; then mkdir log; fi"

restart-%:
	ssh $(TARGET) $(SSH_OPTIONS) -l $(USER) "cd mimir && MOJO_REVERSE_PROXY=1 MOJO_MODE=$(MOJO_MODE) carton exec -- hypnotoad script/mimir"

##
## local commands, to be run *on* the mimir boxes
##
stop  : MOJO_MODE = $(shell hostname | grep -q beta && echo 'beta' || echo 'production')
start : MOJO_MODE = $(shell hostname | grep -q beta && echo 'beta' || echo 'production')

stop:
	MOJO_MODE=$(MOJO_MODE) carton exec -- hypnotoad script/mimir -stop

## starts pre-forked, non-blocking, zero-downtime upgradable daemon
start:
	MOJO_REVERSE_PROXY=1 MOJO_MODE=$(MOJO_MODE) carton exec -- hypnotoad script/mimir

## this is a single foreground process, suitable for running in a
## container (see Dockerfile)
daemon:
	MOJO_REVERSE_PROXY=1 MOJO_MODE=$(MOJO_MODE) carton exec -- script/mimir daemon

graceful: start

restart: stop start

cover: COVER_TESTS=t
cover: MOJO_MODE=beta
cover:
	-@rm -rf cover_db
	MOJO_MODE=$(MOJO_MODE) HARNESS_PERL_SWITCHES=-MDevel::Cover carton exec -- prove -lvr $(COVER_TESTS)
	carton exec -- cover -ignore_re local/ -ignore_re t/


##
## docker targets, to be run in local dev env; will use beta conf by default
## do "make docker-build MOJO_MODE=alpha", etc. to override
##
DOCKER_IMAGE=kay9zero/mimir
DOCKER_NAME=mimir-app

docker-build: MOJO_MODE=beta
docker-build: UID=$(shell id -u)
docker-build: GID=$(shell id -g)
docker-build:
	docker build -t $(DOCKER_IMAGE) --build-arg MOJO_MODE=$(MOJO_MODE) --build-arg UID=$(UID) --build-arg GID=$(GID) .

docker-run:
	docker run -d -p 8080:3000 --name $(DOCKER_NAME) $(DOCKER_IMAGE)

docker-stop:
	docker rm -f $(DOCKER_NAME)

docker-test: MOJO_MODE=beta
docker-test: DOCKER_TESTS=t/model
docker-test:
	docker run -t --rm -e MOJO_MODE=$(MOJO_MODE) kay9zero/mimir carton exec -- prove -lvr $(DOCKER_TESTS)

docker-shell:
	docker run -it --rm $(DOCKER_IMAGE) bash
