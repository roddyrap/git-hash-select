function inline_git_hash_select
{
    declare chosen_commit_hash
    chosen_commit_hash="$(git hash-select ${GIT_HASH_SELECT_NO_COLOR:+--no-color} ${GIT_HASH_SELECT_NO_PREVIEW:+--no-preview} --quiet --inline --no-copy)" || return $?

    LBUFFER+="${chosen_commit_hash}"
}

zle -N inline_git_hash_select
bindkey "${GIT_HASH_SELECT_KEY:-"\\C-g"}" inline_git_hash_select
