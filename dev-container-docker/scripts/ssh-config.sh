#!/usr/bin/env sh

mkdir -p ~/.ssh
cat > ~/.ssh/config << 'SSH_CONFIG'
Host *
    StrictHostKeyChecking accept-new
    VerifyHostKeyDNS yes
SSH_CONFIG
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
