#!/usr/bin/env bash

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  source "./src/package_name_detect.sh"
  source "./src/package_version_detect.sh"
  source "./src/package_version_update.sh"
  source "./src/git.sh"
  source "./src/project.sh"
  source "./src/utils.sh"
  source "./src/logging.sh"

  source "./test/helpers.sh"
}

@test "gather_packages_info returns the root project details" {
  init_text_project /tmp/git_text_project
  cd /tmp/git_text_project

  git init
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

@test "bump minor version for feat commit without pre-release" {
  run increase_version "1.2.3" "feat(parser): add new parsing logic"
  [ "$status" -eq 0 ]
  [ "$output" = "1.3.0" ]
}

@test "bump patch version for fix commit without pre-release" {
  run increase_version "1.2.3" "fix: correct error"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.4" ]
}

@test "bump major version for commit with exclamation mark" {
  run increase_version "1.2.3" "feat!: completely change API"
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "bump major version for commit with BREAKING CHANGE" {
  # Use a literal newline in the commit message.
  commit_msg=$'refactor: update internals\n\nBREAKING CHANGE: changes API'
  run increase_version "1.2.3" "$commit_msg"
  [ "$status" -eq 0 ]
  [ "$output" = "2.0.0" ]
}

@test "append pre-release label when not present" {
  run increase_version "1.2.3" "feat: add new feature" "alpha"
  [ "$status" -eq 0 ]
  [ "$output" = "1.3.0-alpha" ]
}

@test "increment pre-release counter if already present" {
  run increase_version "1.2.3-alpha.0" "fix: bug fix" "alpha"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.4-alpha.1" ]
}

@test "increment pre-release counter if already present no count" {
  run increase_version "1.2.3-alpha" "fix: bug fix" "alpha"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.4-alpha.1" ]
}

@test "increment pre-release counter if already present no count (2nd time)" {
  run increase_version "1.2.3-alpha.1" "fix: bug fix" "alpha"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.4-alpha.2" ]
}

@test "bump patch version for fix commit with different pre-release label" {
  run increase_version "1.2.3" "fix: minor fix" "beta"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.4-beta" ]
}
