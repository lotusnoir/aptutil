GOOS       ?= $(shell go env GOOS)
GOARCH     ?= $(shell go env GOARCH)
export XC_OS = $(GOOS)
export XC_ARCH = $(GOARCH)

SUFFIX     := $(GOOS)_$(GOARCH)

# When the tag name is not available, use the commit hash
TRAVIS_TAG ?= $(shell git rev-parse --short HEAD)

CMD        := $(notdir $(wildcard cmd/*))
ARCHVIE    := $(addsuffix _$(TRAVIS_TAG)_$(SUFFIX).tgz,$(CMD))

GO_PKGS    := \
	github.com/golang/lint/golint \
	github.com/mitchellh/gox


default: test

test:
	go test -v ./...
	go vet -x ./...
	${GOPATH}/bin/golint ./... | xargs -r false

archive: $(ARCHVIE)

bin: $(patsubst %,pkg/%_$(SUFFIX),$(CMD))

pkg/%_$(SUFFIX): cmd/%
	./scripts/build.sh $*

%_$(TRAVIS_TAG)_$(SUFFIX).tgz: pkg/%_$(SUFFIX)
	cp cmd/$*/*.toml $<
	tar -c -z -C pkg/ -f $@ $(notdir $<)

clean:
	rm -rf pkg/ *.tgz

bootstrap:
	go get -u ./...
	go get $(GO_PKGS)

.PHONY: test archive bin clean bootstrap
