#!/usr/bin/env bash

update_node_version() {
  local new_version="$1"
  local updated=0

  # Check if jq is available
  if ! command -v jq >/dev/null; then
    do_error "'jq' application is missing"
  fi

  for file in package.json jsr.json; do
    if [ -f $file ]; then
      jq --arg ver "$new_version" '.version = $ver' $file > $file.tmp \
        && cat $file.tmp > $file \
        && rm $file.tmp

      updated=$((updated + 1))
    fi
  done

  if [ $updated -eq 0 ]; then
    do_error 'Unable to update node version; package.json, jsr.json missing'
  fi
}

update_deno_version() {
  local new_version="$1"
  local updated=0

  for file in package.json jsr.json deno.json; do
    if [ -f $file ]; then
      jq --arg ver "$new_version" '.version = $ver' $file > $file.tmp \
        && cat $file.tmp > $file \
        && rm $file.tmp

      updated=$((updated + 1))
    fi
  done

  if [ $updated -eq 0 ]; then
    do_error 'Unable to update node version; deno.json, deno.jsonc, jsr.json, package.json missing'
  fi
}

# update_go_version() {
#   local new_version="$1"
#   local updated=0

#   if [ -f "version.go" ]; then
#     sed -i -E "s/(const[[:space:]]+Version[[:space:]]*=[[:space:]]*['\"])[^\"]+(['\"])/\1${new_version}\2/" version.go &&
#     updated=1
#   fi

#   if [ $updated -eq 0 ] && [ -f "go.mod" ]; then
#     # Update the version at the end of the module line.
#     sed -i -E "s/^(module[[:space:]]+[^[:space:]]+[[:space:]]+)v[0-9]+\.[0-9]+\.[0-9]+/\1${new_version}/" go.mod &&
#     updated=1
#   fi

#   [ $updated -eq 1 ] || do_error "No version information updated in version.go or go.mod"
# }

# update_python_version() {
#   local new_version="$1"
#   local updated=0

#   if [ -f "__init__.py" ]; then
#     sed -i -E "s/(^[[:space:]]*__version__[[:space:]]*=[[:space:]]*['\"])[^'\"]+(['\"][[:space:]]*$)/\1${new_version}\2/" __init__.py &&
#     updated=1
#   fi

#   if [ $updated -eq 0 ] && [ -f "setup.py" ]; then
#     sed -i -E "s/(version[[:space:]]*=[[:space:]]*['\"])[^'\"]+(['\"])/\1${new_version}\2/" setup.py &&
#     updated=1
#   fi

#   if [ $updated -eq 0 ] && [ -f "pyproject.toml" ]; then
#     sed -i -E "s/(^[[:space:]]*version[[:space:]]*=[[:space:]]*['\"])[^'\"]+(['\"][[:space:]]*$)/\1${new_version}\2/" pyproject.toml &&
#     updated=1
#   fi

#   [ $updated -eq 1 ] || do_error "No version file found in __init__.py, setup.py, or pyproject.toml"
# }

# update_rust_version() {
#   local new_version="$1"
#   if [ ! -f "Cargo.toml" ]; then
#     do_error "Cargo.toml not found"
#   fi

#   sed -i -E "s/(^[[:space:]]*version[[:space:]]*=[[:space:]]*['\"])[^'\"]+(['\"][[:space:]]*$)/\1${new_version}\2/" Cargo.toml ||
#     do_error "Failed to update version in Cargo.toml"
# }

# update_text_version() {
#   local new_version="$1"
#   local version_files=("version" "VERSION" "version.txt" "VERSION.txt")
#   local file found=0

#   for file in "${version_files[@]}"; do
#     if [ -f "$file" ]; then
#       echo "$new_version" > "$file"
#       found=1
#       break
#     fi
#   done

#   [ $found -eq 1 ] || do_error "No version file found (version, VERSION, version.txt, or VERSION.txt)"
# }
