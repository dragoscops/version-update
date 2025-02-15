#!/usr/bin/env bash

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  source "./src/logging.sh"
  source "./src/utils.sh"
  source "./src/version_detect.sh"
}

teardown() {
  for folder in node deno go; do
    rm -rf /tmp/$folder
  done
}

@test "node_detect_version outputs correct version from jsr.json" {
  mkdir -p /tmp/node && cd /tmp/node && npm init -y && cp package.json jsr.json

  run node_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0" ]
}

@test "node_detect_version outputs correct version from package.json if jsr.json absent" {
  mkdir -p /tmp/node && cd /tmp/node && npm init -y

  run node_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0" ]
}

@test "deno_detect_version outputs correct version from jsr.json" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg ver "1.0.0" '.version = $ver' | tee > deno.jsonc \
    && rm deno.json && mv deno.jsonc jsr.json

  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0" ]
}

@test "deno_detect_version outputs correct version from deno.json if jsr.json absent" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg ver "1.0.0" '.version = $ver' | tee > deno.jsonc \
    && rm deno.json && mv deno.jsonc deno.json

  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0" ]
}

@test "deno_detect_version outputs correct version from package.json if deno.json, jsr.json absent" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg ver "1.0.0" '.version = $ver' | tee > deno.jsonc \
    && rm deno.json && mv deno.jsonc package.json

  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0" ]
}

@test "deno_detect_version outputs correct version from deno.jsonc if jsr.json, deno.json, package.json absent" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg ver "1.0.0" '.version = $ver' | tee > deno.jsonc \
    && rm deno.json

  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0" ]
}

@test "go_detect_version outputs correct version from go.mod (no version)" {
  mkdir -p /tmp/go && cd /tmp/go && go mod init github.com/test/go

  run go_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "0.0.1" ]
}

@test "go_detect_version outputs correct version from go.mod" {
  mkdir -p /tmp/go && cd /tmp/go && go mod init github.com/test/go
  echo 'module github.com/test/go 1.0.0' > go.mod

  run go_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.0.0" ]
}

# @test "python_detect_version outputs correct version from __init__.py" {
#   echo '__version__ = "3.0.0"' > /tmp/__init__.py
#   cd /tmp
#   run python_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "3.0.0" ]
# }

# @test "python_detect_version outputs correct version from setup.py if __init__.py absent" {
#   echo 'setup(name="example", version="3.1.0")' > /tmp/setup.py
#   cd /tmp
#   run python_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "3.1.0" ]
# }

# @test "python_detect_version outputs correct version from pyproject.toml if others absent" {
#   echo "[project]
# version = \"3.2.0\"" > /tmp/pyproject.toml
#   cd /tmp
#   run python_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "3.2.0" ]
# }

# # @test "rust_detect_version outputs correct version from Cargo.toml" {
# #   echo '[package]
# # name = "example"
# # version = "0.5.0"
# # ' > /tmp/Cargo.toml
# #   cd /tmp
# #   run rust_detect_version
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "0.5.0" ]
# # }

# @test "text_detect_version outputs correct version from version file" {
#   echo "4.0.0" > /tmp/version.txt
#   cd /tmp
#   run text_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "4.0.0" ]
# }

# # @test "zig_detect_version outputs correct version from build.zig" {
# #   echo 'const version = "0.6.0";' > build.zig
# #   run zig_detect_version
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "0.6.0" ]
# # }

# # @test "zig_detect_version outputs correct version from version.zig if build.zig absent" {
# #   rm -f build.zig
# #   echo 'pub const version = "0.7.0";' > version.zig
# #   run zig_detect_version
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "0.7.0" ]
# # }

# # @test "c_detect_version outputs correct version from version.h" {
# #   echo '#define VERSION "5.0.0"' > version.h
# #   run c_detect_version
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "5.0.0" ]
# # }

# # @test "c_detect_version outputs correct version from CMakeLists.txt if version.h absent" {
# #   rm -f version.h
# #   echo 'set(VERSION "5.1.0")' > CMakeLists.txt
# #   run c_detect_version
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "5.1.0" ]
# # }
