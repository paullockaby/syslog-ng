# stop on error, no built in rules, run silently
MAKEFLAGS="-S -s -r"

# get tag and commit information
IMAGE_COMMIT := $(shell git log -1 | head -n 1 | cut -d" " -f2)
IMAGE_TAG := $(shell git tag --contains ${IMAGE_COMMIT})

# set the version from the tag and commit details
IMAGE_VERSION := $(or $(IMAGE_TAG),$(IMAGE_COMMIT))
ifneq ($(shell git status --porcelain),)
    IMAGE_VERSION := $(IMAGE_VERSION)-dirty
endif

# get image id based on tag or commit
IMAGE_VERSION := $(or $(IMAGE_TAG),$(IMAGE_COMMIT))
IMAGE_NAME := "ghcr.io/paullockaby/syslog-ng"
IMAGE_ID := "${IMAGE_NAME}:${IMAGE_VERSION}"

all: build

.PHONY: build
build:
	@echo "building image for ${IMAGE_ID}"
	docker build -t $(IMAGE_NAME):latest .

.PHONY: buildx
buildx:
	@echo "building multiarch image for ${IMAGE_ID}"
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE_ID) .

.PHONY: push
push:
	@echo "pushing $(IMAGE_ID)"
	docker buildx build --push --platform linux/amd64,linux/arm64 -t $(IMAGE_ID) .

.PHONY: run
run: build
	@echo "running $(IMAGE_NAME):latest"
	docker run --rm -p 514:514/tcp -p 514:514/udp -v $(PWD)/logs:/logs -v $(PWD)/example:/etc/syslog-ng $(IMAGE_NAME):latest

.PHONY: clean
clean:
	@echo "removing built image ${IMAGE_ID}"
	docker image rm -f $(IMAGE_NAME):latest $(IMAGE_ID)
