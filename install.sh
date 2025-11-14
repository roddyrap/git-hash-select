#!/usr/bin/env sh

install_prefix="${1:-/usr/local/}"

# This isn't a perfect verifier, strings like "//" are still accepted.
# This is only meant to find common errors.
if [ -z "${install_prefix}" -o "${install_prefix}" = "/" ]; then
    echo "Error: Invalid installation prefix: \"${install_prefix}\"" >&2
    exit 1
fi

# Standard paths.
bin_dir="${install_prefix}/bin/"
share_dir="${install_prefix}/share/git-hash-select/"

bindings_dir="${share_dir}/bindings"

mkdir -p "${bin_dir}"
mkdir -p "${bindings_dir}"

cp bindings/* "${bindings_dir}/"

cp git-hash-select.sh "${bin_dir}/git-hash-select"
chmod +x "${bin_dir}/git-hash-select"

# Bake-in the current version to the program.
version="$(cat VERSION)"
sed -Ei -e "s/GIT_HASH_SELECT_VERSION=.*/GIT_HASH_SELECT_VERSION=\"${version}\"/" "${bin_dir}/git-hash-select"
