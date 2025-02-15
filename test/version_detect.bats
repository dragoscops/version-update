#!/usr/bin/env bash

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  source "./src/logging.sh"
  source "./src/version_detect.sh"
}

teardown() {
  rm -rf \
    /tmp/__init__.py \
    /tmp/*.json \
    /tmp/deno.jsonc \
    /tmp/go.mod \
    /tmp/mod.ts \
    /tmp/pyproject.toml \
    /tmp/setup.py \
    /tmp/version* \
    /tmp/Cargo.toml \
    /tmp/VERSION*
}

@test "node_detect_version outputs correct version from package.json" {
  echo '{"version": "1.2.3"}' > /tmp/package.json
  cd /tmp
  run node_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.3" ]
}

@test "node_detect_version outputs correct version from jsr.json if package.json absent" {
  echo '{"version": "1.2.3"}' > /tmp/jsr.json
  cd /tmp
  run node_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.3" ]
}

@test "deno_detect_version outputs correct version from deno.json" {
  echo '{"version": "0.9.0"}' > /tmp/deno.json
  cd /tmp
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "0.9.0" ]
}

# @test "deno_detect_version outputs correct version from deno.jsonc if deno.json absent" {
#   echo '{"version": "1.0.0"}' > /tmp/deno.jsonc
#   cd /tmp
#   run deno_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "1.0.0" ]
# }

@test "deno_detect_version outputs correct version from jsr.json if deno.json, deno.jsonc absent" {
  echo '{"version": "1.1.0"}' > /tmp/jsr.json
  cd /tmp
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.1.0" ]
}

@test "deno_detect_version outputs correct version from package.jsonc if deno.json, deno.jsonc, jsr.json absent" {
  echo '{"version": "1.2.0"}' > /tmp/package.json
  cd /tmp
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.0" ]
}

@test "go_detect_version outputs correct version from version.go" {
  echo 'package main; const Version = "2.0.0"' > /tmp/version.go
  cd /tmp
  run go_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "go_detect_version outputs correct version from go.mod comment if version.go absent" {
  echo 'module example.com/mymodule/v2 v2.1.0' > /tmp/go.mod
  cd /tmp
  run go_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.1.0" ]
}

@test "python_detect_version outputs correct version from __init__.py" {
  echo '__version__ = "3.0.0"' > /tmp/__init__.py
  cd /tmp
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.0.0" ]
}

@test "python_detect_version outputs correct version from setup.py if __init__.py absent" {
  echo 'setup(name="example", version="3.1.0")' > /tmp/setup.py
  cd /tmp
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.1.0" ]
}

@test "python_detect_version outputs correct version from pyproject.toml if others absent" {
  echo "[project]
version = \"3.2.0\"" > /tmp/pyproject.toml
  cd /tmp
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.2.0" ]
}

@test "rust_detect_version outputs correct version from Cargo.toml" {
  echo '[package]
name = "example"
version = "0.5.0"
' > /tmp/Cargo.toml
  cd /tmp
  run rust_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "0.5.0" ]
}

@test "detect_version_file outputs correct version from version file" {
  echo "4.0.0" > /tmp/version.txt
  cd /tmp
  run text_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "4.0.0" ]
}

# @test "zig_detect_version outputs correct version from build.zig" {
#   echo 'const version = "0.6.0";' > build.zig
#   run zig_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "0.6.0" ]
# }

# @test "zig_detect_version outputs correct version from version.zig if build.zig absent" {
#   rm -f build.zig
#   echo 'pub const version = "0.7.0";' > version.zig
#   run zig_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "0.7.0" ]
# }

# @test "c_detect_version outputs correct version from version.h" {
#   echo '#define VERSION "5.0.0"' > version.h
#   run c_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "5.0.0" ]
# }

# @test "c_detect_version outputs correct version from CMakeLists.txt if version.h absent" {
#   rm -f version.h
#   echo 'set(VERSION "5.1.0")' > CMakeLists.txt
#   run c_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "5.1.0" ]
# }
