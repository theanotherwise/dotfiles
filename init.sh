#!/usr/bin/env bash

set -euo pipefail

readonly repo_url="https://github.com/theanotherwise/dot.git"
target_dir="$(cd "${HOME:?HOME is not set}" && pwd -P)"
readonly target_dir
readonly submodule_path="${target_dir}/.dot/ai-skills"

git_root="$(git -C "${target_dir}" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ "${git_root}" != "${target_dir}" ]]; then
	git -C "${target_dir}" init --quiet --initial-branch=main
fi

if git -C "${target_dir}" remote get-url origin >/dev/null 2>&1; then
	git -C "${target_dir}" remote set-url origin "${repo_url}"
else
	git -C "${target_dir}" remote add origin "${repo_url}"
fi

git -C "${target_dir}" fetch --quiet --prune origin main
git -C "${target_dir}" checkout --quiet --force -B main origin/main

if [[ -d "${submodule_path}" ]]; then
	submodule_root="$(git -C "${submodule_path}" rev-parse --show-toplevel 2>/dev/null || true)"
	if [[ "${submodule_root}" != "${submodule_path}" ]]; then
		git -C "${target_dir}" submodule deinit --force -- ".dot/ai-skills" >/dev/null 2>&1
	fi
fi

bash "${target_dir}/.dot/setup"
