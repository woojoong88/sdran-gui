export CGO_ENABLED=0
export GO111MODULE=on

.PHONY: build

RAN_SIMULATOR_VERSION := latest
ONOS_BUILD_VERSION := stable

build-gui:
	cd web/sd-ran-gui && npm install && ng build --prod

license_check: # @HELP examine and ensure license headers exist
	@if [ ! -d "../build-tools" ]; then cd .. && git clone https://github.com/onosproject/build-tools.git; fi
	./../build-tools/licensing/boilerplate.py -v --rootdir=${CURDIR}

protos: # @HELP compile the protobuf files (using protoc-go Docker)
	docker run -it -v `pwd`:/go/src/github.com/onosproject/ran-simulator \
		-v `pwd`/../build-tools/licensing:/build-tools/licensing \
		-w /go/src/github.com/onosproject/ran-simulator \
		--entrypoint build/bin/compile-protos.sh \
		onosproject/protoc-go:stable

sd-ran-gui-docker: build-gui # @HELP build onos-gui Docker image
	docker build . -f build/sd-ran-gui/Dockerfile \
		-t onosproject/sd-ran-gui:${RAN_SIMULATOR_VERSION}

images: # @HELP build all Docker images
images: sd-ran-gui-docker

kind: # @HELP build Docker images and add them to the currently configured kind cluster
kind: images
	@if [ "`kind get clusters`" = '' ]; then echo "no kind cluster found" && exit 1; fi
	kind load docker-image onosproject/sd-ran-gui:${RAN_SIMULATOR_VERSION}

all: build images

clean: # @HELP remove all the build artifacts
	rm -rf web/sd-ran-gui/dist web/sd-ran-gui/node_modules

help:
	@grep -E '^.*: *# *@HELP' $(MAKEFILE_LIST) \
    | sort \
    | awk ' \
        BEGIN {FS = ": *# *@HELP"}; \
        {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}; \
    '
