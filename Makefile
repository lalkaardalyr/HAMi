# Makefile for HAMi - Heterogeneous AI Computing Virtualization Middleware

BINARY_NAME ?= hami
IMAGE_NAME ?= hami
IMAGE_TAG ?= latest
REGISTRY ?= ghcr.io/hami-io

GO ?= go
GOFLAGS ?= -trimpath
GOOS ?= linux
GOARCH ?= amd64

GIT_COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

LDFLAGS := -ldflags "-X main.gitCommit=$(GIT_COMMIT) \
	-X main.gitVersion=$(GIT_VERSION) \
	-X main.buildDate=$(BUILD_DATE) \
	-s -w"

.PHONY: all build clean test lint fmt vet docker-build docker-push help

all: build

## build: Build all binaries
build:
	@echo "Building $(BINARY_NAME)..."
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) build $(GOFLAGS) $(LDFLAGS) ./...

## test: Run unit tests
test:
	@echo "Running tests..."
	$(GO) test -v -race -coverprofile=coverage.out ./...

## test-coverage: Show test coverage report
test-coverage: test
	$(GO) tool cover -html=coverage.out -o coverage.html

## lint: Run golangci-lint
lint:
	@echo "Running linter..."
	golangci-lint run ./...

## fmt: Format Go source code
fmt:
	@echo "Formatting code..."
	$(GO) fmt ./...

## vet: Run go vet
vet:
	@echo "Running go vet..."
	$(GO) vet ./...

## clean: Remove build artifacts
clean:
	@echo "Cleaning..."
	rm -f coverage.out coverage.html
	$(GO) clean ./...

## docker-build: Build Docker image
docker-build:
	@echo "Building Docker image $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)..."
	docker build \
		--build-arg GIT_COMMIT=$(GIT_COMMIT) \
		--build-arg GIT_VERSION=$(GIT_VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		-t $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG) .

## docker-push: Push Docker image to registry
docker-push:
	@echo "Pushing Docker image $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)..."
	docker push $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

## generate: Run go generate
generate:
	$(GO) generate ./...

## tidy: Tidy go modules
tidy:
	$(GO) mod tidy

## help: Show this help message
help:
	@echo "Usage: make [target]"
	@echo ""
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /' | column -t -s ':'
