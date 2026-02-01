#!/bin/bash
# Setup npm and git configuration to fix SSH errors with libsignal-node
# 
# This script configures npm and git to use HTTPS instead of SSH when accessing GitHub,
# which prevents "Permission denied (publickey)" errors during npm install.
#
# Usage:
#   bash scripts/setup-npm-git-config.sh
#   # Or with sudo for global config:
#   sudo bash scripts/setup-npm-git-config.sh --global

set -e

GLOBAL_FLAG=""
if [ "$1" = "--global" ]; then
  GLOBAL_FLAG="--global"
  echo "[npm-git-config] Setting up GLOBAL git configuration..."
else
  echo "[npm-git-config] Setting up PROJECT git configuration..."
fi

# Configure git URL redirects to use HTTPS instead of SSH
echo "[npm-git-config] Configuring git to use HTTPS for GitHub..."
git config $GLOBAL_FLAG url."https://github.com/".insteadOf ssh://git@github.com/
echo "[npm-git-config] ✓ Set: url.https://github.com/ insteadOf ssh://git@github.com/"

git config $GLOBAL_FLAG url."https://".insteadOf git://
echo "[npm-git-config] ✓ Set: url.https:// insteadOf git://"

echo "[npm-git-config] Done! Git will now use HTTPS for GitHub repositories."
echo "[npm-git-config] .npmrc also includes git-protocol=https for npm."
