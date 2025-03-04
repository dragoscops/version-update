#!/usr/bin/env bash

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

source "./src/package_name_detect.sh"
source "./src/package_version_detect.sh"
source "./src/package_version_update.sh"
source "./src/git.sh"
source "./src/project.sh"
source "./src/utils.sh"
source "./src/logging.sh"
source "./src/version.sh"

source "./test/helpers.sh"

@test "gather_packages_info returns the root project details" {
  init_text_project /tmp/git_text_project
  cd /tmp/git_text_project

  git init
  git_setup_user
  git add .
  git commit -am "chore: text project init"
  git tag v$(text_detect_version)

  init_deno_project /tmp/git_text_project/packages/deno
  init_go_project /tmp/git_text_project/packages/go
  init_node_project /tmp/git_text_project/packages/node

  cd /tmp/git_text_project
  text_update_version "1.1.0"
  git tag v$(text_detect_version)

  # Run git_get_last_tag
  run gather_workspaces_info

  # Verify that the output matches the latest tag
  assert_success
  assert_output ".:text:git_text_project:1.1.0"
}

@test "gather_workspaces_info returns the packages details" {
  init_text_project /tmp/git_text_project
  cd /tmp/git_text_project

  git init
  git_setup_user
  git add .
  git commit -am "chore: text project init"
  git tag v$(text_detect_version)

  init_deno_project /tmp/git_text_project/packages/deno
  init_go_project /tmp/git_text_project/packages/go
  init_node_project /tmp/git_text_project/packages/node

  cd /tmp/git_text_project
  text_update_version "1.1.0"
  git add .
  git commit -am "chore: text project init"
  git tag v$(text_detect_version)

  # Run git_get_last_tag
  run gather_workspaces_info ".:text,packages/deno:deno,packages/go:go,packages/node:node"

  # Verify that the output matches the latest tag
  assert_success
  assert_output ".:text:git_text_project:1.1.0,packages/deno:deno:deno:1.0.0,packages/go:go:go:0.0.1,packages/node:node:node:1.0.0"
}

@test "gather_changed_workspaces_info returns the packages details" {
  cd /tmp/git_text_project
  echo "$(date +%s)" > date.txt
  git add . && git commit -am "chore: changing main project"

  cd /tmp/git_text_project/packages/deno
  echo "$(date +%s)" > date.txt
  git add . && git commit -am "chore: changing deno project"

  cd /tmp/git_text_project/packages/node
  echo "$(date +%s)" > date.txt
  git add . && git commit -am "chore: changing node project"

  cd /tmp/git_text_project

  # Run git_get_last_tag
  run gather_changed_workspaces_info \
    ".:text,packages/deno:deno,packages/go:go,packages/node:node" \
    "$(git_get_last_created_tag)"

  # Verify that the output matches the latest tag
  assert_success
  assert_output ".:text:git_text_project:1.1.0,packages/deno:deno:deno:1.0.0,packages/node:node:node:1.0.0"
}

@test "increase_workspaces_versions returns the packages details" {
  cd /tmp/git_text_project
  echo "fix: $(date +%s)" > date.txt
  git add . && git commit -am "fix: changing main project"

  commit_message=$(git_get_commit_message)
  last_tag=$(git_get_last_created_tag)
  changed_workspaces_info=$(gather_changed_workspaces_info \
    ".:text,packages/deno:deno,packages/go:go,packages/node:node" \
    "$last_tag")

  run increase_workspaces_versions "$changed_workspaces_info" "$commit_message"

  # Verify that the output matches the latest tag
  assert_success
  assert_output ".:text:git_text_project:1.1.1,packages/deno:deno:deno:1.0.1,packages/node:node:node:1.0.1"
}

@test "update_workspaces_versions returns the packages details" {
  cd /tmp/git_text_project

  workspaces_info=".:text:git_text_project:1.1.1,packages/deno:deno:deno:1.0.1,packages/node:node:node:1.0.1"
  update_workspaces_versions "$workspaces_info"

  run cat version.txt
  assert_success
  assert_output "1.1.1"

  run echo $(cat /tmp/git_text_project/packages/deno/deno.json | jq -r '.version')
  assert_success
  assert_output "1.0.1"

  run echo $(cat /tmp/git_text_project/packages/node/package.json | jq -r '.version')
  assert_success
  assert_output "1.0.1"
}
