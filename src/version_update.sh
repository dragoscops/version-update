#!/usr/bin/env bash

node_update_version() {
  fail_at_missing_command jq

  local new_version="$1"
  local updated=0

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

deno_update_version() {
  fail_at_missing_command jq

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

  if [ -f deno.jsonc ]; then
    deno eval "const file = await Deno.readTextFile('deno.jsonc'); \
      const data = JSON.parse(file.replace(/\/\/.*$/gm, '')); \
      data.version = '2.0.0'; \
      await Deno.writeTextFile('deno.jsonc', JSON.stringify(data, null, 2));"

    updated=$((updated + 1))
  fi

  if [ $updated -eq 0 ]; then
    do_error 'Unable to update node version; deno.json, deno.jsonc, jsr.json, package.json missing'
  fi
}

go_update_version() {
  local new_version="$1"
  local updated=0
  if [ -f "go.mod" ]; then
    # On macOS, use -i '' for in‑place editing.
    sed -i '' -E 's/^(module[[:space:]]+[^[:space:]]+)([[:space:]]+v?[0-9]+\.[0-9]+\.[0-9]+)?/\1 v'"${new_version}"'/' go.mod && updated=1
  fi
  [ $updated -eq 1 ] || do_error "No version information updated in go.mod"
}

# # python_update_version() {
# #   local new_version="$1"
# #   local updated=0

# #   if [ -f "__init__.py" ]; then
# #     sed -i -E "s/(^[[:space:]]*__version__[[:space:]]*=[[:space:]]*['\"])[^'\"]+(['\"][[:space:]]*$)/\1${new_version}\2/" __init__.py &&
# #     updated=1
# #   fi

# #   if [ $updated -eq 0 ] && [ -f "setup.py" ]; then
# #     sed -i -E "s/(version[[:space:]]*=[[:space:]]*['\"])[^'\"]+(['\"])/\1${new_version}\2/" setup.py &&
# #     updated=1
# #   fi

# #   if [ $updated -eq 0 ] && [ -f "pyproject.toml" ]; then
# #     sed -i -E "s/(^[[:space:]]*version[[:space:]]*=[[:space:]]*['\"])[^'\"]+(['\"][[:space:]]*$)/\1${new_version}\2/" pyproject.toml &&
# #     updated=1
# #   fi

# #   [ $updated -eq 1 ] || do_error "No version file found in __init__.py, setup.py, or pyproject.toml"
# # }

# # TODO: Not sure how to update a cargo project yet
# # https://medium.com/codex/rust-modules-and-project-structure-832404a33e2e
# # rust_update_version() {
# #   local new_version="$1"
# #   if [ ! -f "Cargo.toml" ]; then
# #     do_error "Cargo.toml not found"
# #   fi

# #   if ! command -v cargo > /dev/null; then
# #     # https://doc.rust-lang.org/cargo/getting-started/installation.html
# #     curl https://sh.rustup.rs -sSf | sh
# #   fi

# #   # https://github.com/killercup/cargo-edit
# #   cargo --list | grep set-version > /dev/null || cargo install cargo-edit

# #   cargo set-version "$new_version" Cargo.toml \
# #     || do_error 'Failed to update Cargo.toml'
# # }

# text_update_version() {
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

#   if [ $found -ne 1 ]; then
#     do_error "No version file found (version, VERSION, version.txt, or VERSION.txt)"
#   fi
# }
