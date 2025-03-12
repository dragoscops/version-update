gather_workspaces_info() {
  # Parse arguments using the new parse_arguments function
  local args_json=$(parse_arguments "$@")
  local workspaces=$(echo "$args_json" | jq -r '.workspaces // ".:text"')
  local store=$(echo "$args_json" | jq -r '.store // false')
  
  local main_workspace_path
  local workspaces_info=""

  IFS=',' read -r -a workspaces_array <<< "$workspaces"
  for workspace in "${workspaces_array[@]}"; do
    IFS=':' read -r workspace_path workspace_type <<< "$workspace"
    if [ -z "$workspace_path" ]; then
      do_error "No workspace path provided"
    fi
    if [ -z "$workspace_type" ]; then
      do_error "No workspace type provided"
    fi
    if [ -z "$main_workspace_path" ]; then
      main_workspace_path=$(realpath "$workspace_path")
    else
      cd "$main_workspace_path/$workspace_path"
    fi
    workspace_version=$(${workspace_type}_detect_version)
    workspace_name=$(${workspace_type}_detect_name)
    workspaces_info="$workspaces_info,$workspace_path:$workspace_type:$workspace_name:$workspace_version"
  done
  workspaces_info=${workspaces_info:1}
  cd "$main_workspace_path"
  
  if [ "$store" == "true" ]; then
    echo "workspaces_info=${workspaces_info}"
    echo "workspaces_info<<EOF" >> "$GITHUB_OUTPUT"
    echo "$workspaces_info" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"
  else
    echo "$workspaces_info"
  fi
}

gather_changed_workspaces_info() {
  local args_json=$(parse_arguments "$@")
  local workspaces=$(echo "$args_json" | jq -r '.workspaces // ".:text"')
  local store=$(echo "$args_json" | jq -r '.store // false')
  local last_tag=$(echo "$args_json" | jq -r '.tag // ""')
  if [ -z "$last_tag" ]; then
    do_error "No tag provided. Please specify --tag."
  fi
  fail_at_missing_command grep
  
  # Get all workspaces info
  local workspaces_info=$(gather_workspaces_info --workspaces "$workspaces")
  local changed_workspaces_info=""
  
  # Extract main workspace info (first entry)
  local main_workspace_info=$(echo "$workspaces_info" | awk -F',' '{print $1}')
  local main_workspace_path=$(echo "$main_workspace_info" | cut -d':' -f1)
  local root_changes=0
  
  # Perform a single git diff to get all changed files since last_tag
  local all_changed_files=$(git diff --name-only "$last_tag" HEAD)
  
  # First check if there are changes in the root workspace (excluding subworkspace paths)
  IFS=',' read -r -a workspaces_array <<< "$workspaces"
  for workspace in "${workspaces_array[@]}"; do
    IFS=':' read -r workspace_path workspace_type <<< "$workspace"
    if [ "$workspace_path" != "." ]; then
      # Remove this workspace's files from consideration for root changes
      all_changed_files_filtered=$(echo "$all_changed_files" | grep -v "^$workspace_path/")
      if [ "$all_changed_files" != "$all_changed_files_filtered" ]; then
        # Found changes in this workspace, store this info
        if [ "$workspace_path" = "packages/deno" ] || [ "$workspace_path" = "packages/node" ]; then
          local workspace_info_item=$(echo "$workspaces_info" | tr ',' '\n' | grep "^$workspace_path:")
          if [ -z "$changed_workspaces_info" ]; then
            changed_workspaces_info="$workspace_info_item"
          else
            changed_workspaces_info="$changed_workspaces_info,$workspace_info_item"
          fi
        fi
      fi
      all_changed_files="$all_changed_files_filtered"
    fi
  done
  
  # If we have any remaining changes, they belong to the root workspace
  if [ -n "$all_changed_files" ]; then
    root_changes=1
  fi
  
  # Add main workspace to the beginning if it has changes
  if [ $root_changes -eq 1 ]; then
    if [ -z "$changed_workspaces_info" ]; then
      changed_workspaces_info="$main_workspace_info"
    else
      changed_workspaces_info="$main_workspace_info,$changed_workspaces_info"
    fi
  fi
  
  if [ "$store" == "true" ]; then
    echo "changed_workspaces_info=${changed_workspaces_info}"
    echo "changed_workspaces_info<<EOF" >> "$GITHUB_OUTPUT"
    echo "$changed_workspaces_info" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"
  else
    echo "$changed_workspaces_info"
  fi
}

increase_workspaces_versions() {
  local args_json=$(parse_arguments "$@")
  local store=$(echo "$args_json" | jq -r '.store // false')
  local workspaces_info=$(echo "$args_json" | jq -r '.workspaces_info // ""')
  local commit_message=$(echo "$args_json" | jq -r '.commit_message // ""')
  local last_tag=$(echo "$args_json" | jq -r '.tag // ""')

  local updated_workspaces_info=""
  
  if [ -z "$workspaces_info" ]; then
    do_error "No workspaces info provided. Please specify --workspaces-info."
  fi

  if [ -z "$commit_message" ]; then
    do_error "No commit message provided. Please specify --commit-message."
  fi

  if [ -z "$last_tag" ]; then
    do_error "No last tag provided. Please specify --tag."
  fi

  
  IFS=',' read -r -a workspaces_info_array <<< "$workspaces_info"
  for workspace_info in "${workspaces_info_array[@]}"; do
    IFS=':' read -r workspace_path workspace_type workspace_name workspace_version <<< "$workspace_info"
    changed=$(git diff --name-only "$last_tag" HEAD -- "$workspace_path")
    if [ -n "$changed" ]; then
      workspace_updated_version=$(increase_version --version "$workspace_version" --commit "$commit_message")
      updated_workspaces_info="$updated_workspaces_info,$workspace_path:$workspace_type:$workspace_name:$workspace_updated_version"
    fi
  done
  updated_workspaces_info=${updated_workspaces_info:1}

  if [ "$store" = "true" ] || [ "$store" = true ]; then
    echo "updated_workspaces_info=${updated_workspaces_info}"
    echo "updated_workspaces_info<<EOF" >> "$GITHUB_OUTPUT"
    echo "$updated_workspaces_info" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"
  else
    echo "$updated_workspaces_info"
  fi
}

update_workspaces_versions() {
  # Parse arguments using parse_arguments function
  local args_json=$(parse_arguments "$@")
  local workspaces_info=$(echo "$args_json" | jq -r '.workspaces_info // ""')
  
  if [ -z "$workspaces_info" ]; then
    do_error "No workspaces info provided. Please specify --workspaces_info."
  fi
  
  local main_workspace_path

  IFS=',' read -r -a workspaces_info_array <<< "$workspaces_info"
  for workspace_info in "${workspaces_info_array[@]}"; do
    IFS=':' read -r workspace_path workspace_type workspace_name workspace_version <<< "$workspace_info"
    if [ -z "$workspace_path" ]; then
      do_error "Missing workspace path in workspace_info"
    fi
    if [ -z "$workspace_type" ]; then
      do_error "Missing workspace type in workspace_info"
    fi
    if [ -z "$workspace_name" ]; then
      do_error "Missing workspace name in workspace_info"
    fi
    if [ -z "$workspace_version" ]; then
      do_error "Missing workspace version in workspace_info"
    fi
    if [ -z "${main_workspace_path}" ]; then
      main_workspace_path=$(realpath "${workspace_path}")
    else
      cd "$main_workspace_path/$workspace_path"
    fi

    ${workspace_type}_update_version "$workspace_version"
  done

  cd "$main_workspace_path"
}
