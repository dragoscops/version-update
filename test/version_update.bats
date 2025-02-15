#!/usr/bin/env bash

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  source "./src/logging.sh"
  source "./src/version_detect.sh"
  source "./src/version_update.sh"
}

teardown() {
  rm -rf \
    /tmp/__init__.py \
    /tmp/deno.jsonc \
    /tmp/go.mod \
    /tmp/mod.ts \
    /tmp/package.json \
    /tmp/pyproject.toml \
    /tmp/setup.py \
    /tmp/version* \
    /tmp/Cargo.toml \
    /tmp/VERSION*
}

@test "update_node_version updates package.json" {
  # Create a dummy package.json with version "1.0.0"
  echo '{"version": "1.0.0"}' > /tmp/package.json
  cd /tmp
  update_node_version "2.0.0"
  run node_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "update_node_version updates jsr.json" {
  # Create a dummy package.json with version "1.0.0"
  echo '{"version": "1.0.0"}' > /tmp/jsr.json
  cd /tmp
  update_node_version "2.0.0"
  run node_detect_version
  echo $output
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "update_deno_version updates deno.json" {
  # Create a dummy package.json with version "1.0.0"
  echo '{"version": "1.0.0"}' > /tmp/deno.json
  cd /tmp
  update_deno_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

# @test "update_deno_version updates deno.jsonc" {
#   # Create a dummy package.json with version "1.0.0"
#   echo '{"version": "1.0.0"}' > /tmp/deno.jsonc
#   cd /tmp
#   update_deno_version "2.0.0"
#   run deno_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "2.0.0" ]
# }

@test "update_deno_version updates jsr.json" {
  # Create a dummy package.json with version "1.0.0"
  echo '{"version": "1.0.0"}' > /tmp/jsr.json
  cd /tmp
  update_deno_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "update_deno_version updates package.json" {
  # Create a dummy package.json with version "1.0.0"
  echo '{"version": "1.0.0"}' > /tmp/package.json
  cd /tmp
  update_deno_version "2.0.0"
  run deno_detect_version
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

# @test "update_go_version updates version.go" {
#   # Create a dummy version.go with version "1.0.0"
#   echo 'package main; const Version = "1.0.0"' > version.go
#   update_go_version "2.0.0"
#   run go_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "2.0.0" ]
# }

# @test "update_go_version updates go.mod" {
#   # Create a dummy go.mod with a module line that ends with a version
#   echo 'module example.com/mymodule/v2 v1.0.0' > go.mod
#   update_go_version "2.0.0"
#   run go_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "2.0.0" ]
# }

# @test "update_python_version updates __init__.py" {
#   # Create a dummy __init__.py with version "1.0.0"
#   echo '__version__ = "1.0.0"' > __init__.py
#   update_python_version "2.0.0"
#   run python_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "2.0.0" ]
# }

# @test "update_python_version updates setup.py when __init__.py is absent" {
#   rm -f __init__.py
#   echo 'setup(name="example", version="1.0.0")' > setup.py
#   update_python_version "2.0.0"
#   run python_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "2.0.0" ]
# }

# @test "update_python_version updates pyproject.toml when others are absent" {
#   rm -f __init__.py setup.py
#   echo 'version = "1.0.0"' > pyproject.toml
#   update_python_version "2.0.0"
#   run python_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "2.0.0" ]
# }

# @test "update_rust_version updates Cargo.toml" {
#   # Create a dummy Cargo.toml with version "1.0.0"
#   cat <<EOF > Cargo.toml
# [package]
# name = "example"
# version = "1.0.0"
# EOF
#   update_rust_version "2.0.0"
#   run rust_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "2.0.0" ]
# }

# @test "update_text_version updates version file" {
#   # Create a dummy version file (using version.txt)
#   echo "1.0.0" > version.txt
#   update_text_version "2.0.0"
#   run text_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "2.0.0" ]
# }
