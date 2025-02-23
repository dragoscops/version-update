

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
