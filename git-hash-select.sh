#!/usr/bin/env sh

GIT_HASH_SELECT_VERSION="Development"

# Get hashes of previous commits to clipboard. Useful for git commit --fixup.
__internal_git_hash__()
{
	local OPTIND

	# Parse command line arguments (Only quiet fail flag right now).
	local quiet=""
	local should_fzf_preview="yes"
	local show_color="yes"

	while getopts 'qPC' flag; do
		case $flag in
			q) quiet="true" ;;
			C) unset show_color ;;
			P) unset should_fzf_preview ;;
			*) return 129   ;;
		esac
	done

	if [ -n "${show_color}" ]; then
		local git_color_flag="--color=always"
		local fzf_color_flag="--ansi"
	else
		local git_color_flag="--color=never"
	fi

	if [ -n "${should_fzf_preview}" ]; then
		local fzf_preview_command="git show -p ${git_color_flag} {-1}"
	fi

	# Check if inside git, write an error and quit if not.
	local is_git_response="$(git rev-parse --is-inside-work-tree 2>&1)"

	if [ "${is_git_response}" != "true" ]; then
		if [ -z "${quiet}" ]; then
			# Copy pasted the error print from git-status.
			echo "fatal: not a git repository (or any of the parent directories): .git" >&2
		fi

		# git-status and git-commit return 128 when the user isn't in a git repo.
		return 128
	fi

	# Check that there is at least one commit.
	if ! git show HEAD > /dev/null 2>&1; then
		if [ -z "${quiet}" ]; then
			echo "fatal: can't show current commit. Ensure HEAD is a valid commit" >&2
		fi

		return 128
	fi

	# It's important that we set a specific format, because we depend on it when extracting the commit hash.
	local commit_logs="$(git log ${git_color_flag} --format="<%Cgreen%an%Creset> %s %Cblue%h%Creset")"
	local chosen_commit_log="$(echo "${commit_logs}" | fzf --tiebreak=index ${fzf_color_flag} ${fzf_preview_command:+--preview="${fzf_preview_command}"})"

	# The hash is the last word in the known log format.
	local chosen_commit_hash="${chosen_commit_log##* }"

	echo -n "${chosen_commit_hash}"
}

git_hash_select_copy()
{
	local chosen_commit_hash="${1}"
	local stderr_file="${2}"

	# TODO: Add Wayland support in anticipation for Ubuntu 24.04
	if [ "${XDG_SESSION_TYPE}" != "wayland" ]; then
		if which xclip > /dev/null 2> /dev/null; then
			echo -n "${chosen_commit_hash}" | xclip -selection clipboard
		else
			echo "fatal: command should copy to clipboard but xclip isn't installed" > "${stderr_file}"
			return 1
		fi
	else
		echo "fatal: Copying to wayland is not supported" > "${stderr_file}"
		return 1
	fi

	return 0
}

print_git_hash_select_help()
{
	echo "Usage: ${0} [options ...]"
	echo
	echo "-h,--help       	Display this help message"
	echo "-v,--version    	Display the program's version"
	echo "--no-copy       	Do not copy the resulting hash to clipboard"
	echo "--no-print      	Do not print the resulting hash to console (stdout)"
	echo "-C,--no-color   	Don't show colors in the commit picker and preview"
	echo "-P,--no-preview 	Don't show the commit information window"
	echo "--inline        	Don't emit a newline after the commit hash when printing"
	echo "-q,--quiet      	Don't print error messages"
}

git_hash_select()
{
	local OPTIND

	parsed_opts=$(getopt -o "hvqPC" -l "help,version,no-color,no-copy,no-print,no-preview,inline,quiet" -- "${@}")
	if [ $? -ne 0 ]; then
		echo "fatal: Failed to parse command options" >&2
		print_git_hash_select_help >&2
		exit 1
	fi

	eval set -- "$parsed_opts"

	local should_copy_clipboard="yes"
	local should_print="yes"
	local internal_git_hash_flags=""
	local stderr_file="/proc/self/fd/2"
	local echo_print_flags=""

	while true; do
		case "$1" in
		-h|--help)       print_git_hash_select_help; exit 0;;
		-v|--version)    echo "git-hash-select version: ${GIT_HASH_SELECT_VERSION}"; exit 0;;
		--no-copy)       unset should_copy_clipboard;  shift;;
		--no-print)      unset should_print; shift;;
		-C|--no-color)   internal_git_hash_flags="${internal_git_hash_flags} -C"; shift;;
		-P|--no-preview) internal_git_hash_flags="${internal_git_hash_flags} -P"; shift;;
		--inline)        echo_print_flags="${echo_print_flags} -n"; shift;;
		-q|--quiet)      stderr_file="/dev/null"; internal_git_hash_flags="${internal_git_hash_flags} -q"; shift;;
		--)              shift; break ;;
		*)               echo "Unexpected option: $1" >&2; exit 1 ;;
		esac
	done

	# Preserve the exit code of the internal git hash when exiting.
	local chosen_commit_hash
	chosen_commit_hash="$(__internal_git_hash__ ${internal_git_hash_flags})" || return $?

	if [ -n "${should_print}" ]; then
		echo ${echo_print_flags} "${chosen_commit_hash}"
	fi

	if [ -n "${should_copy_clipboard}" ]; then
		git_hash_select_copy "${chosen_commit_hash}" "${stderr_file}" || return $?
	fi
}

git_hash_select ${@}
exit $?
