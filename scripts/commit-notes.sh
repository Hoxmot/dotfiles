#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

${SCRIPT_DIR}/encrypt-decrypt-notes.sh -E
cd .git-backup
git add .
git commit -m "$(date +%Y%m%d-%H%M%S)"
git push

