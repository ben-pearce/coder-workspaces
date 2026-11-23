#!/usr/bin/env sh
set -e

docker system prune -a -f

sudo service docker stop
