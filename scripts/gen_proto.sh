#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROTO_DIR="$ROOT_DIR/proto"
OUT_DIR="$ROOT_DIR/gen/go"

PROTOC_GEN_GO="$(command -v protoc-gen-go || true)"
PROTOC_GEN_GO_GRPC="$(command -v protoc-gen-go-grpc || true)"

for candidate_dir in "${GOBIN:-}" "$(go env GOBIN 2>/dev/null || true)" "$(go env GOPATH 2>/dev/null || true)/bin"; do
  if [[ -z "$PROTOC_GEN_GO" && -n "$candidate_dir" && -x "$candidate_dir/protoc-gen-go" ]]; then
    PROTOC_GEN_GO="$candidate_dir/protoc-gen-go"
  fi

  if [[ -z "$PROTOC_GEN_GO_GRPC" && -n "$candidate_dir" && -x "$candidate_dir/protoc-gen-go-grpc" ]]; then
    PROTOC_GEN_GO_GRPC="$candidate_dir/protoc-gen-go-grpc"
  fi
done

if [[ -z "$PROTOC_GEN_GO" || -z "$PROTOC_GEN_GO_GRPC" ]]; then
  echo "protoc-gen-go 或 protoc-gen-go-grpc 未找到，请先安装到 PATH 或 \$GOBIN/\$GOPATH/bin。" >&2
  exit 1
fi

rm -rf "$OUT_DIR"/*

protoc \
  --proto_path="$PROTO_DIR" \
  --plugin=protoc-gen-go="$PROTOC_GEN_GO" \
  --plugin=protoc-gen-go-grpc="$PROTOC_GEN_GO_GRPC" \
  --go_out=paths=source_relative:"$OUT_DIR" \
  --go-grpc_out=paths=source_relative:"$OUT_DIR" \
  $(find "$PROTO_DIR" -name "*.proto" | sort)

echo "Proto generation complete. Files generated in $OUT_DIR"
