#!/usr/bin/env bash

fail_at_missing_command() {
  local command="$1"

  if ! command -v "$command" >/dev/null; then
    do_error "'$command' application is missing"
  fi
}
