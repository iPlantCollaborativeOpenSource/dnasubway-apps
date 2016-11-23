DOCKER=docker
DEBUG=0
APPLIST="wc fastqc tophat fastx cufflinks cuffmerge cuffdiff"
IMG_NAME="cyverse-dnasub_apps.img"
REBUILD_IMG=1
MD5APP="openssl md5 "

DEPS = .built.base

docker-base:
	if [ ! -f .built.base ]; then build/make-base.sh && touch .built.base; fi

docker-apps: .built.base
	REBUILD=$(REBUILD_IMG) build/make-apps.sh && touch .built.apps

docker-push: docker-apps
	build/make-docker-push.sh 

envs: .built.apps
	build/make-envs.sh

test: .built.apps
	build/make-tests.sh

deploy: .built.apps
	build/make-deploy.sh 

deploy-verify: 
	build/make-deploy-verify.sh

clean:
	rm -rf .built.* assets/*

dist-clean: clean
	build/make-very-clean.sh
