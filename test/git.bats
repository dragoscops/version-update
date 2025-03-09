#!/usr/bin/env bash

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

source "./src/utils.sh"
source "./src/package_version_detect.sh"
source "./src/package_version_update.sh"
source "./src/git.sh"

source "./test/helpers.sh"

@test "git_setup_user configures git for Github" {
  rm -rf $PROJECT_ROOT/tmp/git_text_project
  init_text_project $PROJECT_ROOT/tmp/git_text_project
  cd $PROJECT_ROOT/tmp/git_text_project
  git init

  git_setup_user

  run git config user.name
  assert_success
  assert_output "GitHub Actions"

  run git config user.email
  assert_success
  assert_output "actions@github.com"
}

@test "git_setup_user with gitea parameter" {
  rm -rf $PROJECT_ROOT/tmp/git_text_project_gitea
  init_text_project $PROJECT_ROOT/tmp/git_text_project_gitea
  cd $PROJECT_ROOT/tmp/git_text_project_gitea
  git init

  git_setup_user --gitea

  run git config user.name
  assert_success
  assert_output "GitHub Actions"

  run git config user.email
  assert_success
  assert_output "actions@github.com"
}

@test "git_get_commit_message returns the last commit message, after initializing project" {
  cd $PROJECT_ROOT/tmp/git_text_project

  git add .
  git commit -am "chore: text project init"

  # The last commit is a merge commit.
  run git_get_commit_message

  # Verify that the output matches the expected commit message
  assert_success
  assert_output "chore: text project init"
}

@test "git_get_commit_message with store=true" {
  cd $PROJECT_ROOT/tmp/git_text_project
  # export GITHUB_OUTPUT="$(mktemp)"
  export GITHUB_OUTPUT="$(mktemp)"
  touch $(date +%s).txt
  git add .
  git commit -am "feat: new feature added"

  # Test with named parameter
  run git_get_commit_message --store
  
  assert_success
  assert_output "commit_message=feat: new feature added"
  
  # Check if value was stored in GITHUB_OUTPUT
  run cat "$GITHUB_OUTPUT"
  assert_output --partial "commit_message<<EOF"
  assert_output --partial "feat: new feature added"
  assert_output --partial "EOF"
  unset GITHUB_OUTPUT
}

@test "git_get_last_tag returns initial commit hash when no tags are present" {
  cd $PROJECT_ROOT/tmp/git_text_project

  # Get the initial commit hash
  initial_commit_hash=$(git rev-list --max-parents=0 HEAD)

  # Run git_get_last_tag
  run git_get_last_created_tag

  # Verify that the output matches the initial commit hash
  assert_success
  assert_output "$initial_commit_hash"
}

@test "git_get_last_created_tag with store=true" {
  cd $PROJECT_ROOT/tmp/git_text_project
  export GITHUB_OUTPUT="$(mktemp)"
  git tag v1.2.3
  
  # Test with named parameter
  run git_get_last_created_tag --store
  
  assert_success
  assert_output "last_tag=v1.2.3"
  
  # Check if value was stored in GITHUB_OUTPUT
  run cat "$GITHUB_OUTPUT"
  assert_output --partial "last_tag=v1.2.3"
  unset GITHUB_OUTPUT
}

# @test "git_get_commit_message returns the last commit message, after initializing packages" {
#   cd $PROJECT_ROOT/tmp/git_text_project

#   init_deno_project $PROJECT_ROOT/tmp/git_text_project/packages/deno
#   init_go_project $PROJECT_ROOT/tmp/git_text_project/packages/go
#   init_node_project $PROJECT_ROOT/tmp/git_text_project/packages/node
#   git tag v$(text_detect_version)

#   cd $PROJECT_ROOT/tmp/git_text_project
#   text_update_version "1.1.0"

#   git add .
#   git commit -am "chore: packages init"

#   # The last commit is a merge commit.
#   run git_get_commit_message

#   # Verify that the output matches the expected commit message
#   assert_success
#   assert_output "chore: packages init"
# }

# @test "git_get_last_tag returns the latest tag when tags are present" {
#   cd $PROJECT_ROOT/tmp/git_text_project
#   git tag v$(text_detect_version)

#   # Run git_get_last_tag
#   run git_get_last_created_tag

#   # Verify that the output matches the latest tag
#   assert_success
#   assert_output "v1.1.0"
# }
