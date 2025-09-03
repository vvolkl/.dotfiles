#!/usr/bin/env bash
# Purpose: Scan child directories for Git repositories, then report
#          whether the checked-out branch leads the tracked upstream.
# Usage:   ./git-ahead.sh [parent_directory]
#          Default: current working directory

parent_dir="${1:-.}"

# Predictable globbing
shopt -s nullglob

for dir in "$parent_dir"/*/ ; do
    # Proceed when the directory contains a Git repository
    if [ -d "${dir}/.git" ]; then
        pushd "$dir" > /dev/null

        # Determine current branch or detached-HEAD commit
        branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null \
                 || git rev-parse --short HEAD)"

        # Obtain upstream reference (if configured)
        upstream="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"

        ahead=""
        if [ -n "$upstream" ]; then
            # Count commits ahead/behind
            read -r ahead_cnt behind_cnt < \
              <(git rev-list --left-right --count "$upstream"...HEAD)
            if [ "$ahead_cnt" -gt 0 ]; then
                ahead="⇡$ahead_cnt"
            fi
        else
            upstream="(no upstream)"
        fi

        printf '%-30s  %-25s  %-20s\n' "${dir%/}" "$branch" "$ahead"

        popd > /dev/null
    fi
done
