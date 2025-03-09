git_setup_user() {
  # Parse arguments using the new parse_arguments function
  local args_json=$(parse_arguments "$@")
  local gitea=$(echo "$args_json" | jq -r '.gitea // "false"')

  git config user.name "GitHub Actions"
  git config user.email "actions@github.com"
  if [ ! -z "$GITHUB_WORKSPACE" ]; then
    git config --global --add safe.directory "$GITHUB_WORKSPACE"
  fi
}

git_get_commit_message() {
  # Parse arguments using the new parse_arguments function
  local args_json=$(parse_arguments "$@")
  local store=$(echo "$args_json" | jq -r '.store // "false"')
  
  commit_message=$(git log -1 --no-merges --pretty=format:%B)
  if [ "$store" == "true" ]; then
    echo "commit_message=${commit_message}"
    echo "commit_message<<EOF" >> $GITHUB_OUTPUT
    echo "${commit_message}" >> $GITHUB_OUTPUT
    echo "EOF" >> $GITHUB_OUTPUT
  else 
    echo "${commit_message}"
  fi
}

# git_get_pr_message() {
#   # Parse arguments using the new parse_arguments function
#   local args_json=$(parse_arguments "$@")
#   local store=$(echo "$args_json" | jq -r '.store // "false"')
#   
#   pr_message=$(git log -1 --pretty=format:%B)
#   if [ "$store" == "true" ]; then
#     echo "pr_message=${pr_message}"
#     echo "pr_message<<EOF" >> $GITHUB_OUTPUT
#     echo "${pr_message}" >> $GITHUB_OUTPUT
#     echo "EOF" >> $GITHUB_OUTPUT
#   fi
#   echo "${pr_message}"
# }

git_get_last_created_tag() {
  # Parse arguments using the new parse_arguments function
  local args_json=$(parse_arguments "$@")
  local store=$(echo "$args_json" | jq -r '.store // "false"')
  
  last_tag=$(git for-each-ref --sort=-taggerdate --format '%(refname:short)' refs/tags | tail -n 1)
  if [[ -z "$last_tag" ]]; then
    # last_tag=$(echo "HEAD~$(git rev-list --count HEAD)")
    last_tag=$(git rev-list --max-parents=0 HEAD)
  fi
  if [ "$store" == "true" ]; then
    echo "last_tag=${last_tag}"
    echo "last_tag=${last_tag}" >> $GITHUB_OUTPUT
  else
    echo "${last_tag}"
  fi
}
