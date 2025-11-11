#!/usr/bin/env sh

version="$(cat VERSION)"

install_prefix="${1:-/}"

bin_dir="${install_prefix}/usr/bin/"
share_dir="${install_prefix}/usr/share/git-hash-select/"

mkdir -p "${bin_dir}"
mkdir -p "${share_dir}/bindings/"

cp bindings/* "${share_dir}/bindings/"

cp git-hash-select.sh "${bin_dir}/git-hash-select"
chmod +x "${bin_dir}/git-hash-select"

sed -Ei -e "s/GIT_HASH_SELECT_VERSION=.*/GIT_HASH_SELECT_VERSION=\"${version}\"/" "${bin_dir}/git-hash-select"
