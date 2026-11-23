#!/usr/bin/env sh
set -e

docker system prune -a -f

# Stop the daemon directly; the container may not have a Docker init script.
sudo pkill -TERM dockerd 2>/dev/null || true
