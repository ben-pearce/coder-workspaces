---
display_name: Generic Ubuntu Workspace
description: Provision Coder workspaces as plain Ubuntu containers with Docker-in-Docker, git signing, VS Code Web, Claude Code, and OpenCode.
tags: [docker, container, ubuntu, vscode-web]
---

# Generic Ubuntu Workspace

Provision [Coder workspaces](https://coder.com/docs/workspaces) as plain Ubuntu containers. No devcontainers — a fresh Ubuntu image with git, Docker-in-Docker, and the AI agent CLIs preconfigured.

## Features

- **Fresh Ubuntu** — the workspace image is built from `ubuntu:24.04` at template push time (`build/Dockerfile`).
- **Git** — `coder/git-config` sets the user identity from workspace owner info, and a Coder-managed SSH key signs every commit (`git-commit-signing.sh`).
- **Docker-in-Docker** — the container runs privileged with its own Docker daemon and persistent `/var/lib/docker`, so nested containers can be built and run.
- **VS Code Web** — VS Code Server accessed via the browser, with the Claude Code, Git Graph, OpenCode, and GitHub Actions extensions preinstalled.
- **Claude Code** and **OpenCode** — both CLIs installed and preconfigured to open the workspace folder.

## Parameters

| Name | Type | Description |
| --- | --- | --- |
| `repo_url` | `string` | Optional Git repository cloned into the base directory. Leave empty for a clean workspace. |
| `base_dir` | `string` | Absolute path the repository is cloned into. Defaults to `/home/coder/workspace`. |
| `anthropic_api_key` | `string` | Anthropic API key for Claude Code. Leave empty to authenticate interactively. |
| `claude_code_oauth_token` | `string` | Claude.ai OAuth token from `claude setup-token`. Leave empty to authenticate interactively. |
| `opencode_auth_json` | `string` | OpenCode credentials from `opencode auth export`. Leave empty to authenticate interactively. |

## Architecture

The workspace image is built from `build/Dockerfile`, which starts from `ubuntu:26.04`, installs git, Python, basic networking tools, Docker (for Docker-in-Docker), and supporting tooling, and creates a `coder` user with passwordless sudo.

Two Docker volumes persist data:

- `/home/coder` — the home directory, including AI agent installs and git config.
- `/var/lib/docker` — the inner Docker daemon's data.

Everything else is ephemeral and lost when the workspace restarts.

VS Code Web is the primary access method and opens the cloned repository (or the base directory when no repository is configured). Claude Code and OpenCode are available from the terminal in the same folder.
