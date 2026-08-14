#!/usr/bin/env bash

set -euo pipefail

readonly repo_url="https://github.com/theanotherwise/dot.git"
target_dir="$(cd "${HOME:?HOME is not set}" && pwd -P)"
readonly target_dir
readonly submodule_path="${target_dir}/.dot/ai-skills"
readonly submodule_name=".dot/ai-skills"

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

parent_git_dir="$(git -C "${target_dir}" rev-parse --absolute-git-dir)"
readonly parent_git_dir
readonly submodule_git_dir="${parent_git_dir}/modules/${submodule_name}"

submodule_root="$(git -C "${submodule_path}" rev-parse --show-toplevel 2>/dev/null || true)"
actual_submodule_git_dir="$(git -C "${submodule_path}" rev-parse --absolute-git-dir 2>/dev/null || true)"

if [[ -e "${submodule_path}" ]] && {
	[[ "${submodule_root}" != "${submodule_path}" ]] ||
	[[ "${actual_submodule_git_dir}" != "${submodule_git_dir}" ]] ||
	[[ ! -f "${submodule_git_dir}/config" ]]
}; then
	git -C "${target_dir}" submodule deinit --force -- "${submodule_name}" >/dev/null 2>&1 || true
	rm -rf -- "${submodule_path}"
	rm -rf -- "${submodule_git_dir}"
elif [[ ! -e "${submodule_path}" && -e "${submodule_git_dir}" && ! -f "${submodule_git_dir}/config" ]]; then
	rm -rf -- "${submodule_git_dir}"
fi

bash "${target_dir}/.dot/setup"
