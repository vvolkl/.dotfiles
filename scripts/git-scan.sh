#!/usr/bin/env bash
# Iterate over immediate sub-directories, report branch and cleanliness
# Usage: ./git-scan.sh [parent_directory]
#        Default parent_directory: current working directory

parent_dir="${1:-.}"

# Ensure predictable globbing
shopt -s nullglob

for dir in "$parent_dir"/*/ ; do
    # Proceed only when the sub-directory contains a Git repository
    if [ -d "${dir}/.git" ]; then
        pushd "$dir" > /dev/null

        # Determine checked-out branch (fallback: detached HEAD commit)
        branch="$(git symbolic-ref --short HEAD 2>/dev/null \
                  || git rev-parse --short HEAD)"

        # Detect unstaged or uncommitted changes
        if git diff --quiet && git diff --cached --quiet; then
            dirty_flag=""
        else
            dirty_flag="*"
        fi

        printf '%-30s  %-25s %s\n' "${dir%/}" "${branch}" "${dirty_flag}"

        popd > /dev/null
    fi
done

