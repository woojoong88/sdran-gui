export CGO_ENABLED=0
export GO111MODULE=on

.PHONY: build

RAN_SIMULATOR_VERSION := latest
ONOS_BUILD_VERSION := stable

web/sd-ran-gui/node_modules/@angular/cli/bin/ng: # @HELP Check if NPM install has been done
	cd web/sd-ran-gui && npm install

PHONY: web-sources
web-sources: # @HELP Check if "ng build" has been done
web-sources:
	cd web/sd-ran-gui && ng build --prod

test: # @HELP run the unit tests and source code validation
test: web-sources license_check

license_check: # @HELP examine and ensure license headers exist
	@if [ ! -d "../build-tools" ]; then cd .. && git clone https://github.com/onosproject/build-tools.git; fi
	./../build-tools/licensing/boilerplate.py -v --rootdir=${CURDIR}

protos: # @HELP compile the protobuf files (using protoc-go Docker)
	docker run -it -v `pwd`:/go/src/github.com/onosproject/ran-simulator \
		-v `pwd`/../build-tools/licensing:/build-tools/licensing \
		-w /go/src/github.com/onosproject/ran-simulator \
		--entrypoint build/bin/compile-protos.sh \
		onosproject/protoc-go:stable

PHONY: sd-ran-gui-docker
sd-ran-gui-docker: # @HELP build onos-gui Docker image
sd-ran-gui-docker: web-sources web/sd-ran-gui/node_modules/@angular/cli/bin/ng
	docker build . -f build/sd-ran-gui/Dockerfile \
		-t onosproject/sd-ran-gui:${RAN_SIMULATOR_VERSION}

PHONY: images
images: # @HELP build Docker image
images: sd-ran-gui-docker

kind: # @HELP build Docker images and add them to the currently configured kind cluster
kind: images
	@if [ "`kind get clusters`" = '' ]; then echo "no kind cluster found" && exit 1; fi
	kind load docker-image onosproject/sd-ran-gui:${RAN_SIMULATOR_VERSION}

all: # @HELP build everything
all: images

clean: # @HELP remove all the build artifacts
	rm -rf web/sd-ran-gui/dist web/sd-ran-gui/node_modules

help:
	@grep -E '^.*: *# *@HELP' $(MAKEFILE_LIST) \
    | sort \
    | awk ' \
        BEGIN {FS = ": *# *@HELP"}; \
        {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}; \
    '
