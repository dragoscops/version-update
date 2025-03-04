#!/usr/bin/env bash

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

source "./src/logging.sh"
source "./src/utils.sh"
source "./src/package_version_detect.sh"
source "./src/package_version_update.sh"

source "./test/helpers.sh"

teardown() {
  rm -rf \
    /tmp/deno \
    /tmp/go \
    /tmp/node \
    /tmp/python \
    /tmp/rust \
    /tmp/zig \
    /tmp/text
}

@test "deno_update_version outputs correct version from jsr.json" {
  init_deno_project /tmp/deno jsr.json

  run deno_update_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "deno_update_version outputs correct version from deno.json if jsr.json absent" {
  init_deno_project /tmp/deno deno.json

  run deno_update_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "deno_update_version outputs correct version from deno.jsonc if jsr.json, deno.json absent" {
  init_deno_project /tmp/deno deno.jsonc

  run deno_update_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "deno_update_version outputs correct version from package.json if jsr.json, deno.json, deno.jsonc absent" {
  init_deno_project /tmp/deno package.json

  run deno_update_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "go_update_version outputs correct version from go.mod (no version)" {
  init_go_project
  echo 'module github.com/test/go 1.0.0' > go.mod

  run go_update_version "2.0.0"
  run go_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "go_update_version outputs correct version from go.mod" {
  init_go_project
  echo 'module github.com/test/go 1.0.0' > go.mod

  run go_update_version "2.0.0"
  run go_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "node_update_version outputs correct version from jsr.json" {
  init_node_project /tmp/node jsr.json

  run node_update_version "2.0.0"
  run node_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "node_update_version outputs correct version from package.json if jsr.json absent" {
  init_node_project /tmp/node package.json

  run node_update_version "2.0.0"
  run node_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "python_detect_version version from pyproject.toml (flit or setuptools)" {
  init_python_project /tmp/python pyproject.toml

  run python_update_version "3.3.0"
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.3.0" ]
}

@test "python_detect_version version from pyproject.toml (poetry)" {
  init_python_project /tmp/python pyproject.poetry

  run python_update_version "3.3.0"
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.3.0" ]
}

@test "python_update_version version from setup.cfg if pyproject.toml is missing" {
  init_python_project /tmp/python setup.cfg

  run python_update_version "3.3.0"
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.3.0" ]
}

@test "python_update_version version from setup.py if pyproject.toml, setup.cfg missing" {
  init_python_project /tmp/python setup.py

  run python_update_version "3.3.0"
  run python_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "3.3.0" ]
}

@test "rust_update_version updates Cargo.toml" {
  init_rust_project

  run rust_update_version "2.0.0"
  run rust_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "text_update_version updates version file" {
  init_text_project /tmp/text version.txt

  run text_update_version "2.0.0"
  run text_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}
