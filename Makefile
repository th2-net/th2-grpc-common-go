COMMON_SRC_MAIN_PROTO_DIR=src/main/proto
GITHUB_TH2=github.com/th2-net

TH2_GRPC_COMMON=th2-grpc-common
TH2_GRPC_COMMON_URL=$(GITHUB_TH2)/$(TH2_GRPC_COMMON)@go_package # TODO: replace to a tag after submit PR https://github.com/th2-net/th2-grpc-common/pull/62

MODULE_DIR=pkg/grpc

PROTOC_VERSION=21.12
PROTOC_GEN_GO_VERSION=v1.36.5

init-work-space: configure-grpc-generator generate-grpc-files tidy

configure-grpc-generator:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION)

prepare-grpc-module:
	go get $(TH2_GRPC_COMMON_URL)
	go get google.golang.org/protobuf@$(PROTOC_GEN_GO_VERSION)

generate-grpc-files: prepare-grpc-module tidy
	$(eval $@_COMMON_PROTO_DIR := $(shell go list -m -f '{{.Dir}}' $(TH2_GRPC_COMMON_URL))/$(COMMON_SRC_MAIN_PROTO_DIR))
	protoc \
		--go_out=. \
		--go_opt=module=github.com/th2-net/th2-grpc-common-go \
		--proto_path=$($@_COMMON_PROTO_DIR) \
		$(shell find $($@_COMMON_PROTO_DIR) -name '*.proto' )

tidy:
	go mod tidy -v

build:
	go vet ./...
	go build -v ./...

run-test:
	go test -v -race ./...