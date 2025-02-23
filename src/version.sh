increase_version() {
  local current_version="$1"
  local commit_message="$2"
  local pre_release_label="$3"  # Optional pre-release label, e.g., "alpha"
  local bump="patch"            # Default bump type

  # Determine bump type from commit message:
  if echo "$commit_message" | grep -qi "BREAKING CHANGE"; then
    bump="major"
  else
    local type
    type=$(echo "$commit_message" | awk '{print $1}' | sed -E 's/(\(.*\))?://g')
    if [[ "$type" == *"!" ]]; then
      bump="major"
      type="${type%!}"
    elif [ "$type" = "feat" ]; then
      bump="minor"
    elif [ "$type" = "fix" ]; then
      bump="patch"
    fi
  fi

  # Remove any existing pre-release suffix:
  local base_version="${current_version%%-*}"
  IFS='.' read -r major minor patch <<< "$base_version"

  case "$bump" in
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    patch)
      patch=$((patch + 1))
      ;;
  esac

  local new_version="${major}.${minor}.${patch}"

  # Append pre-release label if provided:
  if [ -n "$pre_release_label" ]; then
    if [[ "$current_version" =~ -${pre_release_label}\.([0-9]+)$ ]]; then
      local num="${BASH_REMATCH[1]}"
      num=$((num + 1))
      new_version="${new_version}-${pre_release_label}.${num}"
    elif [[ "$current_version" =~ -${pre_release_label}$ ]]; then
      # If no numeric counter exists, treat it as .0 and bump to .1.
      new_version="${new_version}-${pre_release_label}.1"
    else
      new_version="${new_version}-${pre_release_label}"
    fi
  fi

  echo "$new_version"
}
