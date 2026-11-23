#!/usr/bin/env sh
set -e

if [ ! -f ~/.init_done ]; then
  cp -rT /etc/skel ~
  touch ~/.init_done
fi
