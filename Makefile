SHELL := bash
.DELETE_ON_ERROR:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-print-directory
BIN := .tmp/bin
COPYRIGHT_YEARS := 2023
LICENSE_IGNORE := --ignore /testdata/
# Set to use a different compiler. For example, `GO=go1.18rc1 make test`.
GO ?= go
BUF_VERSION := v1.25.0

.PHONY: help
help: ## Describe useful make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

.PHONY: all
all: ## Build and lint (default)
	$(MAKE) build
	$(MAKE) lint

.PHONY: clean
clean: ## Delete intermediate build artifacts
	@# -X only removes untracked files, -d recurses into directories, -f actually removes files/dirs
	git clean -Xdf

.PHONY: build ## Build protobuf
build: $(BIN)/buf generate ## Build all packages
	$(BIN)/buf build

.PHONY: lint
lint: $(BIN)/buf ## Lint Go and protobuf
	test -z "$$($(BIN)/buf format -d . | tee /dev/stderr)"
	$(BIN)/buf lint
	$(BIN)/buf format -d --exit-code

.PHONY: lintfix
lintfix: $(BIN)/buf ## Automatically fix some lint errors
	$(BIN)/buf format -w

.PHONY: generate
generate: $(BIN)/license-header ## Regenerate licenses
	$(BIN)/license-header \
		--license-type apache \
		--copyright-holder "Buf Technologies, Inc." \
		--year-range "$(COPYRIGHT_YEARS)" $(LICENSE_IGNORE)

.PHONY: checkgenerate
checkgenerate:
	@# Used in CI to verify that `make generate` doesn't produce a diff.
	test -z "$$(git status --porcelain | tee /dev/stderr)"

$(BIN)/buf: Makefile
	@mkdir -p $(@D)
	GOBIN="$(abspath $(@D))" $(GO) install github.com/bufbuild/buf/cmd/buf@$(BUF_VERSION)

$(BIN)/license-header: Makefile
	@mkdir -p $(@D)
	GOBIN="$(abspath $(@D))" $(GO) install \
		  github.com/bufbuild/buf/private/pkg/licenseheader/cmd/license-header@$(BUF_VERSION)
