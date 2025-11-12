function inline_git_hash_select
    set -l hash_select_flags

    if string length -q -- $GIT_HASH_SELECT_NO_COLOR
        set hash_select_flags $hash_select_flags --no-color
    end

    if string length -q -- $GIT_HASH_SELECT_NO_PREVIEW
        set hash_select_flags $hash_select_flags --no-preview
    end

    set -l commit_hash (git hash-select --inline --quiet --no-copy $hash_select_flags)
    commandline -i "$commit_hash"
end

if ! string length -q -- $GIT_HASH_SELECT_KEY
    set GIT_HASH_SELECT_KEY ctrl-g
end

bind $GIT_HASH_SELECT_KEY inline_git_hash_select
