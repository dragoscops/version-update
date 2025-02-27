
git_setup_user() {
  # if [ "$1" == "--gitea" ]; then echo; fi
  git config user.name "GitHub Actions"
  git config user.email "actions@github.com"
  if [ ! -z "$GITHUB_WORKSPACE" ]; then
    git config --global --add safe.directory "$GITHUB_WORKSPACE"
  fi
}


git_get_commit_message() {
  commit_message=$(git log -1 --no-merges --pretty=format:%B)

  if [ "$1" == "--store" ]; then
    echo "commit_message=${commit_message}"
    echo "commit_message<<EOF" >> $GITHUB_OUTPUT
    echo "${commit_message}" >> $GITHUB_OUTPUT
    echo "EOF" >> $GITHUB_OUTPUT
  fi

  echo "${commit_message}"
}

# git_get_pr_message() {
#   pr_message=$(git log -1 --pretty=format:%B)

#   if [ "$1" == "--store" ]; then
#     echo "pr_message=${pr_message}"
#     echo "pr_message<<EOF" >> $GITHUB_OUTPUT
#     echo "${pr_message}" >> $GITHUB_OUTPUT
#     echo "EOF" >> $GITHUB_OUTPUT
#   fi

#   echo "${pr_message}"
# }

git_get_last_created_tag() {
  last_tag=$(git for-each-ref --sort=-taggerdate --format '%(refname:short)' refs/tags | tail -n 1)
  if [[ -z "$last_tag" ]]; then
    # last_tag=$(echo "HEAD~$(git rev-list --count HEAD)")
    last_tag=$(git rev-list --max-parents=0 HEAD)
  fi

  if [ "$1" == "--store" ]; then
    echo "last_tag=${last_tag}"
    echo "last_tag=${last_tag}" >> $GITHUB_OUTPUT
  fi

  echo "${last_tag}"
}
