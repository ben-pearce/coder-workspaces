#!/usr/bin/env sh
set -eu

mkdir -p ~/.ssh/git-commit-signing

ssh_key=$(curl --request GET \
  --url "${CODER_AGENT_URL}api/v2/workspaceagents/me/gitsshkey" \
  --header "Coder-Session-Token: ${CODER_AGENT_TOKEN}" \
  --silent --show-error)

printf '%s' "$ssh_key" | jq -r .public_key  > ~/.ssh/git-commit-signing/coder.pub
printf '%s' "$ssh_key" | jq -r .private_key > ~/.ssh/git-commit-signing/coder
chmod 600 ~/.ssh/git-commit-signing/coder
chmod 644 ~/.ssh/git-commit-signing/coder.pub

git config --global gpg.format ssh
git config --global commit.gpgsign true
# shellcheck disable=SC2088
git config --global user.signingkey '~/.ssh/git-commit-signing/coder'
