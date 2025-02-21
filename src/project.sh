

gather_packages_info() {
  local workspaces="${1:-.:text}"
  local main_workspace_path

  IFS=',' read -r -a workspaces_array <<< "$workspaces"
  for workspace in "${workspaces_array[@]}"; do
    IFS=':' read -r workspace_path workspace_type <<< "$workspace"

    if [ -z "$main_workspace_path" ]; then
      main_workspace_path=$(pwd)
    else
      cd "$main_workspace_path/$workspace_path"
    fi

    workspace_version=`${workspace_type}_detect_version`
    workspace_name=`${workspace_type}_detect_name`
    echo "$workspace_path:$workspace_type:$workspace_name:$workspace_version"
  done
}
