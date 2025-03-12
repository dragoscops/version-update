#!/usr/bin/env bash

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

source "./src/utils.sh"
source "./src/package_version_detect.sh"
source "./src/package_version_update.sh"
source "./src/git.sh"

source "./test/helpers.sh"

setup() {
  # Create a fresh test repo for each test
  TEST_REPO="$PROJECT_ROOT/tmp/git_test_$(date +%s)_$RANDOM"
  mkdir -p "$TEST_REPO"
  cd "$TEST_REPO"
  git init

  git_setup_user

  # Create initial file
  echo "Initial content" > init.txt
  git add init.txt
  git commit -m "Initial commit"
}

@test "git_setup_user configures git for Github" {
  run git config user.name
  assert_success
  assert_output "GitHub Actions"

  run git config user.email
  assert_success
  assert_output "actions@github.com"
}

@test "git_get_commit_message returns the last commit message" {
  cd "$TEST_REPO"
  git commit --allow-empty -m "chore: test commit"

  run git_get_commit_message

  assert_success
  assert_output "chore: test commit"
}

@test "git_get_commit_message --store to write to GITHUB_OUTPUT" {
  cd "$TEST_REPO"
  export GITHUB_OUTPUT="$(mktemp)"
  git commit --allow-empty -m "feat: new feature added"

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

@test "git_get_last_created_tag returns initial commit hash when no tags are present" {
  cd "$TEST_REPO"
  initial_commit_hash=$(git rev-list --max-parents=0 HEAD)

  run git_get_last_created_tag

  assert_success
  assert_output "$initial_commit_hash"
}

setup_create_tag() { 
  git tag -a "v1.0.0" -m "version 1.0.0"
  echo "test" > test.txt
  git add test.txt
  git commit -m "chore: test commit"
}

@test "git_get_last_created_tag returns tag when tags are present" {
  cd "$TEST_REPO"
  setup_create_tag

  run git_get_last_created_tag

  assert_success
  assert_output "v1.0.0"
}

@test "git_get_last_created_tag --store to write to GITHUB_OUTPUT" {
  cd "$TEST_REPO"
  export GITHUB_OUTPUT="$(mktemp)"
  setup_create_tag
  
  run git_get_last_created_tag --store
  
  assert_success
  assert_output "last_tag=v1.0.0"
  
  run cat "$GITHUB_OUTPUT"
  assert_output --partial "last_tag=v1.0.0"

  unset GITHUB_OUTPUT
}

setup_create_changes() { 
  # Create tag at initial commit
  git tag v0.1.0
  
  # Add commits with conventional commit format
  echo "feature content" > feature.txt
  git add feature.txt
  git commit -m "feat: add first feature"
  
  echo "fix content" > fix.txt
  git add fix.txt
  git commit -m "fix: fix a bug"
  
  echo "docs content" > docs.txt
  git add docs.txt
  git commit -m "docs: update documentation"
}

@test "git_build_changelog returns commits since last tag" {
  cd "$TEST_REPO"
  setup_create_changes
  
  # Run git_build_changelog
  run git_build_changelog --last_tag v0.1.0
  
  # Verify output
  assert_success
  assert_line --regexp "- \([a-f0-9]+\) feat: add first feature"
  assert_line --regexp "- \([a-f0-9]+\) fix: fix a bug"
  assert_line --regexp "- \([a-f0-9]+\) docs: update documentation"
}

@test "git_build_changelog --format markdown to format commits as markdown" {
  cd "$TEST_REPO"
  setup_create_changes
  
  # Run with markdown format
  run git_build_changelog --last_tag v0.1.0 --format markdown
  
  # Verify markdown formatting
  assert_success
  assert_line --regexp "- \*\*✨ Feature\*\* \([a-f0-9]+\): add first feature"
  assert_line --regexp "- \*\*🐛 Fix\*\* \([a-f0-9]+\): fix a bug"
  assert_line --regexp "- \*\*📚 Docs\*\* \([a-f0-9]+\): update documentation"
}

@test "git_build_changelog --format markdown --group_by_type to group commits by type" {
  cd "$TEST_REPO"
  setup_create_changes
  
  # Run with grouped markdown format
  run git_build_changelog --last_tag v0.1.0 --format markdown --group_by_type
  
  # Verify output contains section headers and formatted commits
  assert_success
  assert_output --partial "### 🚀 Features"
  assert_output --partial "### 🐛 Bug Fixes"
  assert_output --partial "### 📚 Documentation"
  
  assert_output --regexp "- [a-f0-9]+: add first feature"
  assert_output --regexp "- [a-f0-9]+: fix a bug"
  assert_output --regexp "- [a-f0-9]+: update documentation"
}

@test "git_build_changelog --store to write to GITHUB_OUTPUT" {
  cd "$TEST_REPO"
  setup_create_changes  
  export GITHUB_OUTPUT="$(mktemp)"
  
  # Run with store option
  run git_build_changelog --last_tag v0.1.0 --store
  
  assert_success
  assert_output --partial "changelog="
  
  # Check if value was stored in GITHUB_OUTPUT
  run cat "$GITHUB_OUTPUT"
  assert_output --partial "changelog<<EOF"
  assert_output --regexp "- \([a-f0-9]+\) feat: add first feature"
  assert_output --regexp "- \([a-f0-9]+\) fix: fix a bug"
  assert_output --regexp "- \([a-f0-9]+\) docs: update documentation"
  assert_output --partial "EOF"
  
  unset GITHUB_OUTPUT
}
