# Version Update Action

**GitHub Action for Automated Version Management**

![GitHub Marketplace](https://img.shields.io/badge/available_on-GitHub%20Marketplace-blue)
![License](https://img.shields.io/github/license/dragoscops/version-update)
![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/dragoscops/version-update?labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit%20Reviews)

Automate the process of versioning your projects with the 
[Version Update Action](https://github.com/dragoscops/version-update). 
This GitHub Action detects changes in specified workspaces, determines the appropriate version increments based on commit messages following [Conventional Commits](https://www.conventionalcommits.org/), updates version files, manages Git operations like creating branches and pull requests, and tags releases seamlessly.

---

## Table of Contents

- [Features](#features)
- [Supported Languages and Version Files](#supported-languages-and-version-files)
- [Usage](#usage)
  - [Prerequisites](#prerequisites)
  - [Basic Workflow](#basic-workflow)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Examples](#examples)
  - [Basic Usage](#basic-usage)
  - [Monorepo Handling](#monorepo-handling)
  - [Direct Commit Without PR](#direct-commit-without-pr)
- [Customization](#customization)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Features

- **Automatic Version Bumping:** Determines whether to increment major, minor, or patch versions based on commit messages.
- **Multi-Workspace Support:** Manage multiple projects or packages within a single repository (monorepo).
- **Semantic Versioning:** Enforces [Semantic Versioning](https://semver.org/) principles.
- **Flexible Configuration:** Customize workspaces, commit messages, and Git operations.
- **Pull Request Integration:** Optionally creates pull requests for version updates.
- **Tagging:** Automatically tags releases with the new version.
- **Supports Multiple Languages:** Compatible with various programming languages and mono repo through customizable workspaces.

---

## Supported Languages and Version Files

The action is designed to be flexible and can work with various project types through the workspace configuration.

### Supported Languages and Version Files

Based on the detection scripts, the action supports:

- **Node.js/JavaScript:** `package.json`, `jsr.json`
- **Deno:** `deno.json`, `deno.jsonc`, `jsr.json`, `package.json`
- **Python:** 
  - `pyproject.toml` (Poetry, Flit, or standard format)
  - `setup.cfg`
  - `setup.py`
- **Go:** `go.mod`
- **Rust:** `Cargo.toml`
- **Text/Generic:** `version`, `VERSION`, `version.txt`, `VERSION.txt`

Each workspace can specify its type to determine how version detection and updating will be handled.

---

## Usage

### Prerequisites

- A GitHub repository with one or more workspaces/projects.
- Commit messages following [Conventional Commits](https://www.conventionalcommits.org/) to determine version increments.
- GitHub token with appropriate permissions to push commits and create pull requests.

### Basic Workflow

1. **Push Changes:** When you push changes to the repository, the action triggers.
2. **Detect Changes:** It detects which workspaces have changed since the last tag.
3. **Determine Version Increment:** Based on commit messages, it decides whether to bump major, minor, or patch versions.
4. **Update Versions:** Updates the version files accordingly.
5. **Commit and PR:** Commits the changes, creates a version branch, and optionally opens a pull request.
6. **Tagging:** Tags the repository with the new version.

---

## Inputs

| Input              | Description                                                    | Required | Default              |
|--------------------|----------------------------------------------------------------|----------|----------------------|
| `github_token`     | **Required.** GitHub Token for performing Git operations.      | Yes      | N/A                  |
| `workspaces`       | Paths to the workspaces within the repository, with type designation (e.g., ".:text"). Separated by commas. | No | `.:text` |
| `version_message`  | Version pull request message.                                  | No       | `version pull request`|
| `no_pr`            | Set to any value to commit directly without creating a PR.     | No       | N/A                  |
| `target_branch`    | Branch to save the version changes to (PR or direct commit).   | No       | `main`               |

---

## Outputs

| Output   | Description                                      |
|----------|--------------------------------------------------|
| `tag`    | Git tag that has been pushed to the repository.  |
| `status` | Status of the version increase (`success` or `failed`). |

---

## Examples

### Basic Usage

Automatically update the version when changes are pushed to the `main` branch using default settings.

```yaml
name: Version Update

on:
  push:
    branches:
      - main

jobs:
  version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Important for git history

      - name: Version Update
        uses: dragoscops/version-update@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Monorepo Handling

Handle multiple workspaces with their respective configuration.

```yaml
name: Version Update Monorepo

on:
  push:
    branches:
      - main

jobs:
  version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Important for git history

      - name: Version Update
        uses: dragoscops/version-update@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          workspaces: ".:text;packages/frontend:javascript,packages/backend:python"
          version_message: "chore: update versions"
```

### Direct Commit Without PR

Commit version changes directly without creating a pull request by setting `no_pr`.

```yaml
name: Version Update Direct Commit

on:
  push:
    branches:
      - main

jobs:
  version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Important for git history

      - name: Version Update
        uses: dragoscops/version-update@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          no_pr: "true"
```

---

## Customization

### Defining Multiple Workspaces

Customize the `workspaces` input to handle multiple projects within your repository.

```yaml
with:
  workspaces: "workspace1:type1,workspace2:type2,workspace3:type3"
```

> **Important:** In a monorepo setup, the first workspace listed becomes the main workspace if you don't explicitly set the root directory (.:type). The main workspace's version is used for tag creation. In the example above, `workspace1:type1` will determine the version used for Git tags.

### Version Message

Change the commit message used when updating versions.

```yaml
with:
  version_message: "chore: bump versions based on changes"
```

### No Pull Request

If you prefer direct commits over pull requests for version updates, enable the `no_pr` flag.

```yaml
with:
  no_pr: "true"
```

### Target Branch

Specify a different target branch for pull requests or direct commits.

```yaml
with:
  target_branch: "develop"
```

---

## Contributing

Contributions are welcome! Whether it's bug fixes, new features, or improving documentation, your input is valuable.

1. **Fork the Repository**

2. **Create a Feature Branch**

   ```bash
   git checkout -b feature/YourFeature
   ```

3. **Commit Your Changes**

   ```bash
   git commit -m "Add your message"
   ```

4. **Push to the Branch**

   ```bash
   git push origin feature/YourFeature
   ```

5. **Open a Pull Request**

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contact

For any questions or support, please open an issue on the 
[GitHub repository](https://github.com/dragoscops/version-update/issues).
