#!/usr/bin/env bash

export SED_I_CMD="sed -i"
uname -a | grep Darwin > /dev/null && export SED_I_CMD="sed -i ''"

fail_at_missing_command() {
  local command="$1"

  if ! command -v "$command" >/dev/null; then
    do_error "'$command' application is missing"
  fi
}

which_python() {
  if command -v "python3" >/dev/null; then
    echo python3
    return
  fi
  if command -v "python" >/dev/null; then
    echo python
    return
  fi
}
