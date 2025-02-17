#!/usr/bin/env bash

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  source "./src/logging.sh"
  source "./src/utils.sh"
  source "./src/package_name_detect.sh"
}

teardown() {
  for folder in cargo deno go node python rust text; do
    rm -rf /tmp/$folder
  done
}

@test "deno_detect_name outputs correct version from jsr.json" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg name "deno" '.name = $name' | tee > deno.jsonc \
    && rm deno.json && mv deno.jsonc jsr.json

  run deno_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "deno" ]
}

@test "deno_detect_name outputs correct version from deno.json if jsr.json absent" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg name "deno" '.name = $name' | tee > deno.jsonc \
    && rm deno.json && mv deno.jsonc deno.json

  run deno_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "deno" ]
}

@test "deno_detect_name outputs correct version from deno.jsonc if deno.json, jsr.json absent" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg name "deno" '.name = $name' | tee > deno.jsonc \
    && rm deno.json

  run deno_detect_name
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "deno" ]
}

@test "deno_detect_name outputs correct version from package.json if jsr.json, deno.json, deno.jsonc absent" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg name "deno" '.name = $name' | tee > deno.jsonc \
    && rm deno.json && mv deno.jsonc package.json

  run deno_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "deno" ]
}

@test "go_detect_name outputs correct version from go.mod (no version)" {
  mkdir -p /tmp/go && cd /tmp/go && go mod init github.com/test/go

  run go_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "go" ]
}

@test "go_detect_name outputs correct version from go.mod" {
  mkdir -p /tmp/go && cd /tmp/go && go mod init github.com/test/go
  echo 'module github.com/test/go 1.0.0' > go.mod

  run go_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "go" ]
}

@test "node_detect_name outputs correct version from jsr.json" {
  mkdir -p /tmp/node && cd /tmp/node && npm init -y && cp package.json jsr.json

  run node_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "node" ]
}

@test "node_detect_name outputs correct version from package.json if jsr.json absent" {
  mkdir -p /tmp/node && cd /tmp/node && npm init -y

  run node_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "node" ]
}

@test "python_detect_name outputs correct version from pyproject.toml (flit or setuptools)" {
  mkdir -p /tmp/python && cd /tmp/python && cat > pyproject.toml <<EOF
[project]
name = "python"
version = "3.2.0"
dependencies = [
    "requests",
    'importlib-metadata; python_version<"3.10"',
]
EOF

  run python_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "python" ]
}

@test "python_detect_name outputs correct version from pyproject.toml (poetry)" {
  mkdir -p /tmp/python && cd /tmp/python && cat > pyproject.toml <<EOF
[tool.poetry]
name = "python"
version = "3.2.0"
description = "Calculate word counts in a text file!"
authors = ["Tomas Beuzen"]
license = "MIT"
readme = "README.md"
EOF

  run python_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "python" ]
}

@test "python_detect_name outputs correct version from setup.cfg if pyproject.toml is missing" {
  mkdir -p /tmp/python && cd /tmp/python && cat > setup.cfg <<EOF
[metadata]
name = python
version = 3.2.0

[options]
install_requires =
    requests
    importlib-metadata; python_version<"3.10"
EOF

  run python_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "python" ]
}

@test "python_detect_name outputs correct version from setup.py if pyproject.toml, setup.cfg missing" {
  mkdir -p /tmp/python && cd /tmp/python && cat > setup.py <<EOF
from setuptools import setup

setup(
    name='python',
    version='3.2.0',
    install_requires=[
        'requests',
        'importlib-metadata; python_version<"3.10"',
    ],
)
EOF

  run python_detect_name
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "python" ]
}

@test "rust_detect_name outputs correct version from Cargo.toml" {
  mkdir -p /tmp/cargo && cd /tmp/cargo && cargo init

  run rust_detect_name
  [ "$status" -eq 0 ]
  [ "$output" = "cargo" ]
}

@test "text_detect_name outputs correct version from version file" {
  mkdir -p /tmp/text && cd /tmp/text && echo "1.0.0" > version.txt

  run text_detect_name
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "text" ]
}

# # @test "zig_detect_name outputs correct version from build.zig" {
# #   echo 'const version = "0.6.0";' > build.zig
# #   run zig_detect_name
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "0.6.0" ]
# # }

# # @test "zig_detect_name outputs correct version from version.zig if build.zig absent" {
# #   rm -f build.zig
# #   echo 'pub const version = "0.7.0";' > version.zig
# #   run zig_detect_name
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "0.7.0" ]
# # }

# # @test "c_detect_name outputs correct version from version.h" {
# #   echo '#define VERSION "5.0.0"' > version.h
# #   run c_detect_name
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "5.0.0" ]
# # }

# # @test "c_detect_name outputs correct version from CMakeLists.txt if version.h absent" {
# #   rm -f version.h
# #   echo 'set(VERSION "5.1.0")' > CMakeLists.txt
# #   run c_detect_name
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "5.1.0" ]
# # }
