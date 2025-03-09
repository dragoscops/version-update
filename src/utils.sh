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

# Parse command line arguments into a JSON string
# Usage: args_json=$(parse_arguments "$@")
parse_arguments() {
  # Check if jq is available
  fail_at_missing_command "jq"
  
  local args_array=()
  local positional=()
  
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --*)
        # Handle --option value pairs
        local key="${1:2}" # Remove leading --
        if [[ "$#" -gt 1 && ! "$2" == --* ]]; then
          # It's a key-value pair
          args_array+=("--arg" "$key" "$2")
          shift
        else
          # It's a flag (--flag) with no value
          args_array+=("--arg" "$key" "true")
        fi
        ;;
      -*)
        # Handle short options (-h, -v)
        local key="${1:1}" # Remove leading -
        if [[ "$#" -gt 1 && ! "$2" == -* ]]; then
          # It's a key-value pair
          args_array+=("--arg" "$key" "$2")
          shift
        else
          # It's a flag (-h) with no value
          args_array+=("--arg" "$key" "true")
        fi
        ;;
      *)
        # Handle positional arguments
        positional+=("$1")
        ;;
    esac
    shift
  done
  
  # Start with an empty JSON object
  local json="{}"
  
  # Add named arguments to the JSON object
  for ((i=0; i<${#args_array[@]}; i+=3)); do
    json=$(jq "${args_array[i]}" "${args_array[i+1]}" "${args_array[i+2]}" \
          '. + {($ARGS.named): $ARGS.positional}' \
          --null-input --args "$json")
  done
  
  # Add positional arguments if they exist
  if [[ ${#positional[@]} -gt 0 ]]; then
    # Convert positional array to JSON array
    local pos_json=$(printf '%s\n' "${positional[@]}" | jq -R . | jq -s .)
    json=$(jq --argjson pos "$pos_json" '. + {"positional": $pos}' <<< "$json")
  fi
  
  echo "$json"
}
