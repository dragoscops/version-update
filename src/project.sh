

gather_workspaces_info() {
  local workspaces="${1:-.:text}"
  local main_workspace_path
  local workspaces_info=""

  IFS=',' read -r -a workspaces_array <<< "$workspaces"

  for workspace in "${workspaces_array[@]}"; do
    IFS=':' read -r workspace_path workspace_type <<< "$workspace"

    if [ -z "$main_workspace_path" ]; then
      main_workspace_path=$(pwd)
    else
      cd "$main_workspace_path/$workspace_path"
    fi

    workspace_version=$(${workspace_type}_detect_version)
    workspace_name=$(${workspace_type}_detect_name)

    workspaces_info="$workspaces_info,$workspace_path:$workspace_type:$workspace_name:$workspace_version"
  done
  workspaces_info=${workspaces_info:1}

  if [ "$2" == "--store" ]; then
    echo "workspaces_info<<EOF" >> "$GITHUB_OUTPUT"
    echo "$workspaces_info" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"
  else
    echo "$workspaces_info"
  fi
}

gather_changed_workspaces_info() {
  local workspaces="${1:-.:text}"
  local last_tag="$2"

  local workspaces_info=$(gather_workspaces_info "$workspaces")
  local changed_workspaces_info=""

  IFS=',' read -r -a workspaces_info_array <<< "$workspaces_info"
  for workspace_info in "${workspaces_info_array[@]}"; do
    IFS=':' read -r workspace_path a b c <<< "$workspace_info"
    changed=$(git diff --name-only "$last_tag" HEAD -- "$workspace_path")
    if [ -n "$changed" ]; then
      changed_workspaces_info="$changed_workspaces_info,$workspace_info"
    fi
  done
  changed_workspaces_info=${changed_workspaces_info:1}

  if [ "$3" == "--store" ]; then
    echo "changed_workspaces_info<<EOF" >> "$GITHUB_OUTPUT"
    echo "$changed_workspaces_info" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"
  else
    echo "$changed_workspaces_info"
  fi
}

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

  # If a pre-release label is provided, append it:
  if [ -n "$pre_release_label" ]; then
    if [[ "$current_version" =~ -${pre_release_label}\.([0-9]+)$ ]]; then
      local num="${BASH_REMATCH[1]}"
      num=$((num + 1))
      new_version="${new_version}-${pre_release_label}.${num}"
    else
      new_version="${new_version}-${pre_release_label}"
    fi
  fi

  echo "$new_version"
}
