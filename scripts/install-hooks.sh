#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
hooks_dir="$repo_root/.githooks"

if [[ ! -d "$hooks_dir" ]]; then
  echo ".githooks 디렉터리를 찾을 수 없습니다: $hooks_dir"
  exit 1
fi

chmod +x "$hooks_dir"/commit-msg "$hooks_dir"/pre-commit
git config core.hooksPath .githooks

echo "로컬 Git 훅이 활성화되었습니다. (core.hooksPath=.githooks)"
