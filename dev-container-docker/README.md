---
display_name: Docker-in-Docker Dev Containers
description: Provision Docker containers as Coder workspaces running Dev Containers via Docker-in-Docker.
tags: [docker, container, devcontainer]
---

# Docker-in-Docker Dev Containers

Provision [Coder workspaces](https://coder.com/docs/workspaces) as Docker containers that run [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) via Docker-in-Docker.

## Parameters

| Name | Type | Description |
| --- | --- | --- |
| `repo_url` | `string` | Main project repository, cloned first into the base directory. It must contain the `devcontainer.json` that defines the development environment. |
| `base_dir` | `string` | Base directory the repositories are cloned into. Defaults to `~/project`. |
| `additional_repo_urls` | `list(string)` | Additional repositories, cloned into the base directory alongside the main project. |

## Architecture

The workspace runs the `codercom/enterprise-node:ubuntu` image, which includes Docker and Node.js for the `@devcontainers/cli` tool. Docker-in-Docker lets each workspace run its own Docker daemon.

Two Docker volumes persist data:

- `/home/coder` — the home directory.
- `/var/lib/docker` — the inner Docker daemon's data.

Everything else is ephemeral and lost when the workspace restarts. Data inside individual Dev Containers persists only as defined by each project's `devcontainer.json`.
