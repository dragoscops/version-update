# Version Update Action

**GitHub Action for Automated Version Management**

<!-- ![GitHub Marketplace](https://img.shields.io/badge/available_on-GitHub%20Marketplace-blue) -->
![License](https://img.shields.io/github/license/dragoscops/version-update)

Automate the process of versioning your projects with the [Version Update Action](https://github.com/yourusername/version-update). This GitHub Action detects changes in specified workspaces, determines the appropriate version increments based on commit messages following [Conventional Commits](https://www.conventionalcommits.org/), updates version files, manages Git operations like creating branches and pull requests, and tags releases seamlessly.

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
  - [Dry Run Mode](#dry-run-mode)
- [Customization](#customization)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Features

- **Automatic Version Bumping:** Determines whether to increment major, minor, or patch versions based on commit messages.
- **Multi-Workspace Support:** Manage multiple projects or packages within a single repository (monorepo).
- **Semantic Versioning:** Enforces [Semantic Versioning](https://semver.org/) principles.
- **Flexible Configuration:** Customize workspaces, version files, commit messages, and Git operations.
- **Pull Request Integration:** Optionally creates pull requests for version updates.
- **Tagging:** Automatically tags releases with the new version.
- **Supports Multiple Languages:** Compatible with Node.js, Python, Go, Deno, TypeScript, and more.

---

## Supported Languages and Version Files

The action supports a variety of programming languages and their respective version file formats. Extendable via the `action_lib.sh` script to support additional types.

### Supported Version Files

- **Node.js:** `package.json`
- **Python:**
  - `__init__.py`
  - `setup.py`
  - `pyproject.toml`
- **Go:** `go.mod`
- **Deno:** `deno.jsonc`, `mod.ts`, `version.ts`
- **Generic:** `name`, `NAME`, `name.txt`, `NAME.txt`, `version`, `VERSION`, `version.txt`, `VERSION.txt`
- **Others:** Extendable by modifying `action_lib.sh`

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

| Input         | Description                                                                 | Required | Default              |
|---------------|-----------------------------------------------------------------------------|----------|----------------------|
| `github_token`| **Required.** GitHub Token for performing Git operations (commits, PRs).   | Yes      | N/A                  |
| `workspaces`  | Paths to the workspaces within the repository, separated by commas.         | No       | `.`                  |
| `version_files`| Version files to look for in each workspace, separated by commas.          | No       | `package.json`       |
| `version_message`| Commit message for the version update.                                  | No       | `version pull request`|
| `no_pr`       | If set, the action will commit changes directly without creating a PR.     | No       | `false`              |
| `dry_run`     | If set, the action will not make any changes but will print commands.       | No       | `false`              |

---

## Outputs

| Output           | Description                                     |
|------------------|-------------------------------------------------|
| `version_branch` | Name of the branch created for version updates. |
| `pr_title`       | Title of the pull request created for version updates. |
| `tag`            | Git tag that has been pushed to the repository. |

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

      - name: Version Update
        uses: yourusername/version-update@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Monorepo Handling

Handle multiple workspaces (e.g., `packages/frontend`, `packages/backend`) with their respective version files.

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

      - name: Version Update
        uses: yourusername/version-update@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          workspaces: "packages/frontend,packages/backend"
          version_files: "package.json,setup.py"
          version_message: "chore: update versions"
```

### Direct Commit Without PR

Commit version changes directly without creating a pull request by setting `no_pr` to `true`.

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

      - name: Version Update
        uses: yourusername/version-update@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          no_pr: true
```

### Dry Run Mode

Run the action in dry run mode to see what changes would occur without applying them.

```yaml
name: Version Update Dry Run

on:
  push:
    branches:
      - main

jobs:
  version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Version Update
        uses: yourusername/version-update@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          dry_run: true
```

---

## Customization

### Defining Multiple Workspaces

Customize the `workspaces` and `version_files` inputs to handle multiple projects within your repository.

```yaml
with:
  workspaces: "workspace1,workspace2,workspace3"
  version_files: "package.json,setup.py,go.mod"
```

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
  no_pr: true
```

### Dry Run

Enable `dry_run` to simulate the action without making any changes. Useful for testing.

```yaml
with:
  dry_run: true
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
