#!/usr/bin/env sh

echo "$(cat /proc/loadavg | awk '{ print $1 }') $(nproc)" | awk '{ printf "%0.2f", $1/$2 }'
