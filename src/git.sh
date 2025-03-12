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
  local args_json=$(parse_arguments "$@")
  local store=$(echo "$args_json" | jq -r '.store // "false"')
  
  last_tag=$(git for-each-ref --sort=-taggerdate --format '%(refname:short)' refs/tags | head -n 1)
  if [[ -z "$last_tag" ]]; then
    last_tag=$(git rev-list --max-parents=0 HEAD)
  fi
  if [ "$store" == "true" ]; then
    echo "last_tag=${last_tag}"
    echo "last_tag=${last_tag}" >> $GITHUB_OUTPUT
  else
    echo "${last_tag}"
  fi
}

git_build_changelog() {
  # Parse arguments using the new parse_arguments function
  local args_json=$(parse_arguments "$@")
  local last_tag=$(echo "$args_json" | jq -r '.last_tag // ""')
  local format=$(echo "$args_json" | jq -r '.format // "list"')
  local store=$(echo "$args_json" | jq -r '.store // "false"')
  local group_by_type=$(echo "$args_json" | jq -r '.group_by_type // "false"')
  
  # If no last_tag provided, get it
  if [[ -z "$last_tag" ]]; then
    last_tag=$(git_get_last_created_tag)
  fi
  
  # Generate the changelog
  local changelog

  # Base commit log format includes hash in parentheses
  changelog=$(git log --no-merges "${last_tag}..HEAD" --pretty=format:"- (%h) %s" | grep -v "Merge")
  
  if [[ "$format" == "markdown" ]]; then
    if [[ "$group_by_type" == "true" ]]; then
      # Create separate sections for each commit type using more macOS-compatible commands
      local features=$(echo "$changelog" | grep -E '\([a-f0-9]+\) feat' || echo "")
      local fixes=$(echo "$changelog" | grep -E '\([a-f0-9]+\) fix' || echo "")
      local docs=$(echo "$changelog" | grep -E '\([a-f0-9]+\) docs' || echo "")
      local style=$(echo "$changelog" | grep -E '\([a-f0-9]+\) style' || echo "")
      local refactor=$(echo "$changelog" | grep -E '\([a-f0-9]+\) refactor' || echo "")
      local perf=$(echo "$changelog" | grep -E '\([a-f0-9]+\) perf' || echo "")
      local test=$(echo "$changelog" | grep -E '\([a-f0-9]+\) test' || echo "")
      local build=$(echo "$changelog" | grep -E '\([a-f0-9]+\) build' || echo "")
      local ci=$(echo "$changelog" | grep -E '\([a-f0-9]+\) ci' || echo "")
      local chore=$(echo "$changelog" | grep -E '\([a-f0-9]+\) chore' || echo "")
      
      # Catch any other commits not matching conventional format
      local filtered_types="feat|fix|docs|style|refactor|perf|test|build|ci|chore"
      local other=$(echo "$changelog" | grep -v -E "\([a-f0-9]+\) ($filtered_types)" || echo "")
      
      # Build a well-formatted markdown changelog with headers
      changelog=""
      
      if [[ -n "$features" ]]; then
        changelog+="### 🚀 Features\n\n"
        changelog+="$(echo "$features" | sed -E 's/- \(([a-f0-9]+)\) feat(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi
      
      if [[ -n "$fixes" ]]; then
        changelog+="### 🐛 Bug Fixes\n\n"
        changelog+="$(echo "$fixes" | sed -E 's/- \(([a-f0-9]+)\) fix(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi
      
      if [[ -n "$docs" ]]; then
        changelog+="### 📚 Documentation\n\n"
        changelog+="$(echo "$docs" | sed -E 's/- \(([a-f0-9]+)\) docs(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi
      
      if [[ -n "$style" ]]; then
        changelog+="### 💎 Style\n\n"
        changelog+="$(echo "$style" | sed -E 's/- \(([a-f0-9]+)\) style(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi
      
      if [[ -n "$refactor" ]]; then
        changelog+="### ♻️ Refactor\n\n"
        changelog+="$(echo "$refactor" | sed -E 's/- \(([a-f0-9]+)\) refactor(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi
      
      if [[ -n "$perf" ]]; then
        changelog+="### ⚡ Performance\n\n"
        changelog+="$(echo "$perf" | sed -E 's/- \(([a-f0-9]+)\) perf(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi
      
      if [[ -n "$test" ]]; then
        changelog+="### ✅ Tests\n\n"
        changelog+="$(echo "$test" | sed -E 's/- \(([a-f0-9]+)\) test(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi
      
      if [[ -n "$build" ]]; then
        changelog+="### 🏗️ Build\n\n"
        changelog+="$(echo "$build" | sed -E 's/- \(([a-f0-9]+)\) build(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi
      
      if [[ -n "$ci" ]]; then
        changelog+="### 👷 CI\n\n"
        changelog+="$(echo "$ci" | sed -E 's/- \(([a-f0-9]+)\) ci(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi
      
      if [[ -n "$chore" ]]; then
        changelog+="### 🔧 Chore\n\n"
        changelog+="$(echo "$chore" | sed -E 's/- \(([a-f0-9]+)\) chore(\([^)]+\))?:\s*/- \1: /g')\n\n"
      fi

      if [[ -n "$other" ]]; then
        changelog+="### Other Changes\n\n$other\n\n"
      fi
      
      # Remove trailing newlines
      changelog=$(echo -e "$changelog" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')
    else
      # Simple formatting with commit type highlighted
      changelog=$(echo "$changelog" |
        sed -E 's/- \(([a-f0-9]+)\) feat(\([^)]+\))?:/- **✨ Feature** (\1):/g' |
        sed -E 's/- \(([a-f0-9]+)\) fix(\([^)]+\))?:/- **🐛 Fix** (\1):/g' |
        sed -E 's/- \(([a-f0-9]+)\) docs(\([^)]+\))?:/- **📚 Docs** (\1):/g' |
        sed -E 's/- \(([a-f0-9]+)\) style(\([^)]+\))?:/- **💎 Style** (\1):/g' |
        sed -E 's/- \(([a-f0-9]+)\) refactor(\([^)]+\))?:/- **♻️ Refactor** (\1):/g' |
        sed -E 's/- \(([a-f0-9]+)\) perf(\([^)]+\))?:/- **⚡ Performance** (\1):/g' |
        sed -E 's/- \(([a-f0-9]+)\) test(\([^)]+\))?:/- **✅ Test** (\1):/g' |
        sed -E 's/- \(([a-f0-9]+)\) build(\([^)]+\))?:/- **🏗️ Build** (\1):/g' |
        sed -E 's/- \(([a-f0-9]+)\) ci(\([^)]+\))?:/- **👷 CI** (\1):/g' |
        sed -E 's/- \(([a-f0-9]+)\) chore(\([^)]+\))?:/- **🔧 Chore** (\1):/g')
    fi
  fi
  
  # Store or output the changelog
  if [ "$store" == "true" ]; then
    echo "changelog=${changelog}"
    echo "changelog<<EOF" >> $GITHUB_OUTPUT
    echo "${changelog}" >> $GITHUB_OUTPUT
    echo "EOF" >> $GITHUB_OUTPUT
  else
    echo "${changelog}"
  fi
}

# git_create_version_branch() {
#   local args_json=$(parse_arguments "$@")
#   local version=$(echo "$args_json" | jq -r '.version // ""')
#   local pr_title=$(echo "$args_json" | jq -r '.pr_title // ""')
#   local pr_message=$(echo "$args_json" | jq -r '.pr_message // ""')

#   version_branh="release_branch_v${version//./_}"

#   git checkout -b $version_branch
#   git add .
#   git commit -am "chore: ${pr_title}"
#   git push origin $version_branch

#   gh pr create --base main --head "$version_branch" \
#     --title "${pr_title}" --body "${pr_message}"
# }

# git_commit_version_changes() {
#   local args_json=$(parse_arguments "$@")
#   local version=$(echo "$args_json" | jq -r '.version // ""')
#   local pr_title=$(echo "$args_json" | jq -r '.pr_title // ""')
#   local pr_message=$(echo "$args_json" | jq -r '.pr_message // ""')

#   git add .
#   git commit -am "chore: ${pr_title} ${pr_message}"
#   git push origin main

#   git_create_tag --version "$version" --tag_message "$pr_title"
# }

# git_create_tag() {
#   local args_json=$(parse_arguments "$@")
#   local version=$(echo "$args_json" | jq -r '.version // ""')
#   local tag_message=$(echo "$args_json" | jq -r '.tag_message // ""')

#   git tag -a "v$version" -m "$tag_message"
#   git push origin "v$version"
# }