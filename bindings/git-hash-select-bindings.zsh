function inline_git_hash_select
{
    declare chosen_commit_hash
    chosen_commit_hash="$(git hash-select ${@} ${GIT_HASH_SELECT_NO_COLOR:+--no-color} ${GIT_HASH_SELECT_NO_PREVIEW:+--no-preview} --quiet --inline --no-copy)" || return $?

    LBUFFER+="${chosen_commit_hash}"
}

zle -N inline_git_hash_select
bindkey "${GIT_HASH_SELECT_KEY:-"\\C-g"}" inline_git_hash_select

# Becuase using alt/shift doesn't work in all terminals, I did not find a freat key command for
# reflog binding. The option is still available for people who select their preffered key.
if [ -n "${GIT_HASH_SELECT_REFLOG_KEY}" ]; then
    function inline_git_hash_select_reflog
    {
        inline_git_hash_select --reflog
    }

    zle -N inline_git_hash_select_reflog
    bindkey -- "${GIT_HASH_SELECT_REFLOG_KEY}" inline_git_hash_select_reflog
fi
