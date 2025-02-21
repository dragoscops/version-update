#!/usr/bin/env bash

setup() {
load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  source "./src/package_name_detect.sh"
  source "./src/package_version_detect.sh"
  source "./src/package_version_update.sh"
  source "./src/git.sh"
  source "./src/project.sh"

  source "./test/helpers.sh"
}

@test "git_get_commit_message returns the last commit message, after initializing project" {
  init_text_project /tmp/git_text_project
  cd /tmp/git_text_project

  git init
  git add .
  git commit -am "chore: text project init"

  # The last commit is a merge commit.
  run git_get_commit_message

  # Verify that the output matches the expected commit message
  assert_success
  assert_output "chore: text project init"
}

@test "git_get_last_tag returns initial commit hash when no tags are present" {
  cd /tmp/git_text_project

  # Get the initial commit hash
  initial_commit_hash=$(git rev-list --max-parents=0 HEAD)

  # Run git_get_last_tag
  run git_get_last_created_tag

  # Verify that the output matches the initial commit hash
  assert_success
  assert_output "$initial_commit_hash"
}

@test "git_get_commit_message returns the last commit message, after initializing packages" {
  cd /tmp/git_text_project

  init_deno_project /tmp/git_text_project/packages/deno
  init_go_project /tmp/git_text_project/packages/go
  init_node_project /tmp/git_text_project/packages/node
  git tag v$(text_detect_version)

  cd /tmp/git_text_project
  text_update_version "1.1.0"

  git add .
  git commit -am "chore: packages init"

  # The last commit is a merge commit.
  run git_get_commit_message

  # Verify that the output matches the expected commit message
  assert_success
  assert_output "chore: packages init"
}

@test "git_get_last_tag returns the latest tag when tags are present" {
  cd /tmp/git_text_project
  git tag v$(text_detect_version)

  # Run git_get_last_tag
  run git_get_last_created_tag

  # Verify that the output matches the latest tag
  assert_success
  assert_output "v1.1.0"
}
