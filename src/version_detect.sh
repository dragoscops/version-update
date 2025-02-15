#!/usr/bin/env bash

node_detect_version() {
  # Check if jq is available
  if ! command -v jq >/dev/null; then
    do_error "'jq' application is missing"
  fi

  # Check if package.json exists
  if [ -f package.json ]; then
    jq -r '.version' package.json
    return
  fi

  # Check if jsr.json exists
  if [ -f jsr.json ]; then
    jq -r '.version' jsr.json
    return
  fi

  # Use jq directly on the file to output the version in compact form
  do_error "No version information found in pacjage.json, jsr.json"
}

deno_detect_version() {
  # Ensure jq is available
  if ! command -v jq >/dev/null; then
    do_error "'jq' application is missing"
  fi

  # Check if deno.json exists
  if [ -f deno.json ]; then
    jq -r '.version' deno.json
    return
  fi

  # Check if deno.jsonc exists
  if [ -f deno.jsonc ]; then
    # jq -r '.version' deno.json
    do_error "'deno.jsonc' is not supported yet"
    return
  fi

  # Check if jsr.json exists
  if [ -f jsr.json ]; then
    jq -r '.version' jsr.json
    return
  fi

  # Check if package.json exists
  if [ -f package.json ]; then
    jq -r '.version' package.json
    return
  fi

  do_error "No version information found in deno.json, deno.jsonc, jsr.json, package.json"
}

go_detect_version() {
  # Check if version.go exists and contains a version declaration
  if [ -f "version.go" ]; then
    version=$(grep -E 'const\s+Version\s*=' version.go | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -n "$version" ]; then
      echo "$version"
      return
    fi
  fi

  # Fallback: Check go.mod for a version comment (e.g., // version: "1.2.3")
  if [ -f "go.mod" ]; then
    version=$(grep -E '^module ' go.mod |
      sed -nE 's/^module[[:space:]]+[^[:space:]]+[[:space:]]+v([0-9]+\.[0-9]+\.[0-9]+).*/\1/p')
    if [ -n "$version" ]; then
      echo "$version"
      return
    fi
  fi

  do_error "No version information found in version.go or go.mod"
}

python_detect_version() {
  # Check __init__.py for a __version__ variable declaration.
  if [ -f "__init__.py" ]; then
    version=$(grep -E '__version__\s*=\s*["'\'']([^"\'']+)["'\'']' __init__.py |
      sed -nE "s/^[[:space:]]*__version__[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*$/\1/p")
    if [ -n "$version" ]; then
      echo "$version"
      return
    fi
  fi

  # Fallback: Check setup.py for a version parameter in the setup() call.
  if [ -f "setup.py" ]; then
    version=$(grep -E 'version\s*=\s*["'\'']([^"\'']+)["'\'']' setup.py | head -n 1 | sed -E 's/.*version\s*=\s*["'\'']([^"\'']+)["'\''].*/\1/')
    if [ -n "$version" ]; then
      echo "$version"
      return
    fi
  fi

  # Fallback: Check pyproject.toml for a version key.
  if [ -f "pyproject.toml" ]; then
    if ! command -v yq > /dev/null; then
      do_error "'yq' application is missing"
    fi

    yq e '.project.version' pyproject.toml
    return
  fi

  do_error "No version information found in __init__.py, setup.py, or pyproject.toml"
}

rust_detect_version() {
  # Ensure Cargo.toml exists
  if [ ! -f "Cargo.toml" ]; then
    do_error "Cargo.toml not found"
  fi

  if ! command -v yq > /dev/null; then
    do_error "'yq' application is missing"
  fi

  yq e '.package.version' Cargo.toml
}

text_detect_version() {
  # List of candidate version file names
  local version_files=("version" "VERSION" "version.txt" "VERSION.txt")
  local file version

  # Loop over each candidate file
  for file in "${version_files[@]}"; do
    if [ -f "$file" ]; then
      # Read the first non-empty line from the file and trim whitespace
      version=$(grep -m 1 . "$file" | tr -d ' \t\n\r')
      if [ -n "$version" ]; then
        echo "$version"
        return 0
      fi
    fi
  done

  do_error "No version information found in any version file (version, VERSION, version.txt, or VERSION.txt)"
}

# zig_detect_version() {
#   if [ -f "build.zig" ]; then
#     version=$(grep -E 'const\s+version\s*=\s*".+"' build.zig | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')
#     if [ -n "$version" ]; then
#       echo "$version"
#       return
#     fi
#   fi

#   if [ -f "version.zig" ]; then
#     version=$(grep -E 'pub\s+const\s+version\s*=\s*".+"' version.zig | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')
#     if [ -n "$version" ]; then
#       echo "$version"
#       return
#     fi
#   fi

#   do_error "No version information found in build.zig or version.zig"
# }

# c_detect_version() {
#   if [ -f "version.h" ]; then
#     version=$(grep -E '#define\s+VERSION\s+"[^"]+"' version.h | head -n 1 | sed -E 's/#define\s+VERSION\s+"([^"]+)".*/\1/')
#     if [ -n "$version" ]; then
#       echo "$version"
#       return
#     fi
#   fi

#   if [ -f "CMakeLists.txt" ]; then
#     version=$(grep -E 'set\s*\(\s*VERSION\s+"[^"]+"' CMakeLists.txt | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')
#     if [ -n "$version" ]; then
#       echo "$version"
#       return
#     fi
#   fi

#   do_error "No version information found in version.h or CMakeLists.txt"
# }
