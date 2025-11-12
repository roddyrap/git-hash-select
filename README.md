# Git hash-select


![Using shell bindings](./shell-bindings.gif)

## Description

### Standalone command

`git hash-select` is a minimal command to help with retrieving commit hashes.

Using fzf it's possible to retrieve commit hashes directly to clipboard using full-screen fuzzy search (Without erasing the text on terminal before-hand).

The command is compltely POSIX shell-based, with no compiled code, which makes it minimally compatible with all architectures and almost all Linux distributions.

Using git hash-select is as simple as typing `git hash-select` in your shell after the installation. Type `git hash-select -h` to see what you can do with it!

### Shell Bindings

The most useful feature of the `git hash-select` package is the optional shell binding. \
The package comes with an optional shell binding that can be sourced for increased productivity.
Pressing Ctrl+g when in a git repository will open an inline version of the commit picker, inserting the hash directly into the line.

The supported shells are: Bash, Zshell and Dash.

Using the bindings:

```bash
# Put the correct file extension according to your shell
GIT_HASH_BINDINGS_FILE="/usr/share/git-hash-select/bindings/git-hash-select-bindings.bash"
if [ -f "${GIT_HASH_BINDINGS_FILE}" ]; then
    source "${GIT_HASH_BINDINGS_FILE}"
fi
```

The binding is configurable, with options being togglable by modifying environment values:

```bash
GIT_HASH_SELECT_KEY # If set then overrides the default key binding ("\\C-g", Ctrl+g)
GIT_HASH_SELECT_NO_COLOR # If set when sourcing then color is disabled in selector.
GIT_HASH_SELECT_NO_PREVIEW # If set when sourcing then the commit preview window is turned off.
```

## Installation

For Archlinux: `git-hash-select` is available on the AUR

For all other Linux systems:
Running the `./install.sh` script will set-up the files in the correct location on your PC.

Currently non-Linux systems (MacOS, Windows) aren't supported.
