#!/usr/bin/env bash

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  source "./src/logging.sh"
  source "./src/utils.sh"
  source "./src/version_detect.sh"
  source "./src/version_update.sh"
}

teardown() {
  for folder in cargo deno go node python rust; do
    rm -rf /tmp/$folder
  done
}

@test "deno_update_version outputs correct version from jsr.json" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg ver "1.0.0" '.version = $ver' | tee > deno.jsonc \
    && rm deno.json && mv deno.jsonc jsr.json

  run deno_update_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "deno_update_version outputs correct version from deno.json if jsr.json absent" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg ver "1.0.0" '.version = $ver' | tee > deno.jsonc \
    && rm deno.json && mv deno.jsonc deno.json

  run deno_update_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "deno_update_version outputs correct version from package.json if deno.json, jsr.json absent" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg ver "1.0.0" '.version = $ver' | tee > deno.jsonc \
    && rm deno.json && mv deno.jsonc package.json

  run deno_update_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "deno_update_version outputs correct version from deno.jsonc if jsr.json, deno.json, package.json absent" {
  cd /tmp && deno init deno && cd /tmp/deno \
    && cat deno.json | jq --arg ver "1.0.0" '.version = $ver' | tee > deno.jsonc \
    && rm deno.json

  run deno_update_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "go_update_version outputs correct version from go.mod (no version)" {
  mkdir -p /tmp/go && cd /tmp/go && go mod init github.com/test/go

  run go_update_version "2.0.0"
  run go_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "go_update_version outputs correct version from go.mod" {
  mkdir -p /tmp/go && cd /tmp/go && go mod init github.com/test/go
  echo 'module github.com/test/go 1.0.0' > go.mod

  run go_update_version "2.0.0"
  run go_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "node_update_version outputs correct version from jsr.json" {
  mkdir -p /tmp/node && cd /tmp/node && npm init -y && cp package.json jsr.json

  run node_update_version "2.0.0"
  run node_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "node_update_version outputs correct version from package.json if jsr.json absent" {
  mkdir -p /tmp/node && cd /tmp/node && npm init -y

  run node_update_version "2.0.0"
  run node_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "python_detect_version version from pyproject.toml (flit or setuptools)" {
  mkdir -p /tmp/python && cd /tmp/python && cat > pyproject.toml <<EOF
[project]
name = "mypackage"
version = "3.2.0"
dependencies = [
    "requests",
    'importlib-metadata; python_version<"3.10"',
]
EOF

  run python_update_version "3.3.0"
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.3.0" ]
}

@test "python_detect_version version from pyproject.toml (poetry)" {
  mkdir -p /tmp/python && cd /tmp/python && cat > pyproject.toml <<EOF
[tool.poetry]
name = "pycounts"
version = "3.2.0"
description = "Calculate word counts in a text file!"
authors = ["Tomas Beuzen"]
license = "MIT"
readme = "README.md"
EOF

  run python_update_version "3.3.0"
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.3.0" ]
}

@test "python_update_version version from setup.cfg if pyproject.toml is missing" {
  mkdir -p /tmp/python && cd /tmp/python && cat > setup.cfg <<EOF
[metadata]
name = mypackage
version = 3.2.0

[options]
install_requires =
    requests
    importlib-metadata; python_version<"3.10"
EOF

  run python_update_version "3.3.0"
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.3.0" ]
}

@test "python_update_version version from setup.py if pyproject.toml, setup.cfg missing" {
  mkdir -p /tmp/python && cd /tmp/python && cat > setup.py <<EOF
from setuptools import setup

setup(
    name='mypackage',
    version='3.2.0',
    install_requires=[
        'requests',
        'importlib-metadata; python_version<"3.10"',
    ],
)
EOF

  run python_update_version "3.3.0"
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.3.0" ]
}

@test "rust_update_version updates Cargo.toml" {
  mkdir -p /tmp/cargo && cd /tmp/cargo && cargo init > /dev/null

  run rust_update_version "2.0.0"
  run rust_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "text_update_version updates version file" {
  mkdir -p /tmp/test && cd /tmp/test && echo "1.0.0" > version.txt

  run text_update_version "2.0.0"
  run text_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}
