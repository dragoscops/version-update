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

@test "git_get_commit_message returns the last commit message" {
  init_text_project /tmp/git_text_project
  cd /tmp/git_text_project

  git init
  git add .
  git commit -am "chore: text project init"
  git tag v$(text_detect_version)

  # The last commit is a merge commit.
  run git_get_commit_message

  # Verify that the output matches the expected commit message
  assert_success
  assert_output "chore: text project init"
}

# @test "git_get_commit_message returns the last commit message, after initializing project" {
#   init_text_project /tmp/git_text_project
#   cd /tmp/git_text_project

#   git init
#   git add .
#   git commit -am "chore: text project init"
#   git tag v$(text_detect_version)

#   init_deno_project /tmp/git_text_project/packages/deno
#   init_go_project /tmp/git_text_project/packages/go
#   init_node_project /tmp/git_text_project/packages/node

#   cd /tmp/git_text_project
#   text_update_version "1.1.0"

#   git add .
#   git commit -am "chore: packages init"
#   git tag v$(text_detect_version)

#   # The last commit is a merge commit.
#   run git_get_commit_message

#   # Verify that the output matches the expected commit message
#   assert_success
#   assert_output "chore: packages init"
# }

# @test "git_get_commit_message returns the last commit message, after initializing packages" {
#   init_text_project /tmp/git_text_project
#   cd /tmp/git_text_project

#   git init
#   git add .
#   git commit -am "chore: text project init"
#   git tag v$(text_detect_version)

#   init_deno_project /tmp/git_text_project/packages/deno
#   init_go_project /tmp/git_text_project/packages/go
#   init_node_project /tmp/git_text_project/packages/node

#   cd /tmp/git_text_project
#   text_update_version "1.1.0"

#   git add .
#   git commit -am "chore: packages init"
#   git tag v$(text_detect_version)

#   # The last commit is a merge commit.
#   run git_get_commit_message

#   # Verify that the output matches the expected commit message
#   assert_success
#   assert_output "chore: packages init"
# }
