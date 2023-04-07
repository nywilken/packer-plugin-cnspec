NAME=cnspec
BINARY=packer-plugin-${NAME}

COUNT?=1
TEST?=$(shell go list ./...)
HASHICORP_PACKER_PLUGIN_SDK_VERSION?=$(shell go list -m github.com/hashicorp/packer-plugin-sdk | cut -d " " -f2)

.PHONY: dev

build:
	CGO_ENABLED=0 go build -o ${BINARY} -ldflags="-X go.mondoo.com/packer-plugin-cnspec/version.Version=0.0.0 -X go.mondoo.com/packer-plugin-cnspec/version.Build=dev"

dev: build
	@mkdir -p ~/.packer.d/plugins/
	@mv ${BINARY} ~/.packer.d/plugins/${BINARY}
	
test:
	@go test -race -count $(COUNT) $(TEST) -timeout=3m

test/golanglint:
	@golangci-lint run

install-packer-sdc: ## Install packer software development command
	@go install github.com/hashicorp/packer-plugin-sdk/cmd/packer-sdc@${HASHICORP_PACKER_PLUGIN_SDK_VERSION}

ci-release-docs: install-packer-sdc
	@packer-sdc renderdocs -src docs -partials docs-partials/ -dst docs/
	@/bin/sh -c "[ -d docs ] && zip -r docs.zip docs/"

plugin-check: install-packer-sdc build
	@packer-sdc plugin-check ${BINARY}

testacc: dev
	@PACKER_ACC=1 go test -count $(COUNT) -v $(TEST) -timeout=120m

generate: install-packer-sdc
	@go generate ./...
	packer-sdc renderdocs -src ./docs -dst ./.docs -partials ./docs-partials
	# checkout the .docs folder for a preview of the docs