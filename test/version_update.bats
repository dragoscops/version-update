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
  for folder in node deno go; do
    rm -rf /tmp/$folder
  done
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

# # @test "python_update_version updates __init__.py" {
# #   # Create a dummy __init__.py with version "1.0.0"
# #   echo '__version__ = "1.0.0"' > __init__.py
# #   python_update_version "2.0.0"
# #   run python_detect_version
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "2.0.0" ]
# # }

# # @test "python_update_version updates setup.py when __init__.py is absent" {
# #   rm -f __init__.py
# #   echo 'setup(name="example", version="1.0.0")' > setup.py
# #   python_update_version "2.0.0"
# #   run python_detect_version
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "2.0.0" ]
# # }

# # @test "python_update_version updates pyproject.toml when others are absent" {
# #   rm -f __init__.py setup.py
# #   echo 'version = "1.0.0"' > pyproject.toml
# #   python_update_version "2.0.0"
# #   run python_detect_version
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "2.0.0" ]
# # }

# # @test "rust_update_version updates Cargo.toml" {
# #   # Create a dummy Cargo.toml with version "1.0.0"
# #   cat <<EOF > /tmp/Cargo.toml
# # [package]
# # name = "example"
# # version = "1.0.0"
# # EOF
# #   cd /tmp

# #   rust_update_version "2.0.0"
# #   run rust_detect_version
# #   [ "$status" -eq 0 ]
# #   [ "$output" = "2.0.0" ]
# # }

# @test "text_update_version updates version file" {
#   # Create a dummy version file (using version.txt)
#   echo "1.0.0" > /tmp/version.txt
#   cd /tmp

#   text_update_version "2.0.0"
#   run text_detect_version
#   [ "$status" -eq 0 ]
#   [ "$output" = "2.0.0" ]
# }
