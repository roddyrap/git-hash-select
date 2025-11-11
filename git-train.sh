#!/usr/bin/env sh

# Dependencies: git (Duh), xargs.

set -e
set -o pipefail

function git_is_in_tree()
{
    # Check if inside git, write an error and quit if not.
    local is_git_response="$(git rev-parse --is-inside-work-tree 2>&1)"
    if [ "${is_git_response}" != "true" ]; then
        return 1
    fi

    return 0
}

function git_get_remote_head()
{
    local remote="${1}"

    declare remote_info

    remote_info="$(git remote show "${remote}" 2>/dev/null)"
    if [ $? != 0 ]; then
        return 1
    fi

    echo "${remote_info}" | grep -E "HEAD branch" | sed -Ene "s/\s*HEAD branch: (\w+).*/\1/p"
}

# TODO: Can show branches from the remotes (non-local), which is bad.
function git_train_show()
{
    declare remote branch

    remote="${1:-origin}"
    branch="$(git_get_remote_head ${remote})"
    if [ $? != 0 ]; then
        return 1
    fi

    # TODO: git-cherry is problematic here because it shows all of the differences, including splits if they exist.
    #       I want to only see direct descendents.
    git cherry ${remote}/${branch} HEAD | tr -d '+ ' | git name-rev --annotate-stdin --name-only | sed -Ene "s/(.*?)~.*/\1/p" | uniq
}

# What to print when no command is given.
function git_train_summary()
{
    local remote="${1:-origin}"
    git_train_show "${remote}" | xargs echo "Branches:"
}

# TODO: Make remote an optional argument so that it wouldn't be mandatory to pass if you want to add arguments to push.
function git_train_push()
{
    local remote="${1:-origin}"

    local branches="$(git_train_show "${remote}" | xargs)"
    echo "Pushing branches:" ${branches}
    git push ${@:2} "${remote}" ${branches}
}

function git_train()
{
    local action="${1}"

    # Check if inside git, write an error and quit if not.
    if ! git_is_in_tree; then
        echo "Not a git repo!" >&2
        return 1
    fi

    if [ -z "${action}" ]; then
        git_train_summary
    elif [ "${action}" == "show" ]; then
        git_train_show ${@:2}
    elif [ "${action}" == "push" ]; then
        git_train_push ${@:2}
    fi

    return $?
}

git_train $@
