#!/usr/bin/env bash

set -e

script_version="$(cat VERSION)"
debian_revision="1"
version="${script_version}-${debian_revision}"

creation_dir="$(mktemp -d)"

# Create control tar

control_creation_dir="$(mktemp -d)"

cp debian/control "${control_creation_dir}/control"
sed -Eie "s/Version:\s+[0-9A-Za-z_:.-]+/Version: ${version}/" "${control_creation_dir}/control"

tar --owner=0 --group=0 -czf "${creation_dir}/control.tar.gz" -C "${control_creation_dir}/" control

# Create data tar

data_creation_dir="$(mktemp -d)"
mkdir "${data_creation_dir}/usr/"
./install.sh "${data_creation_dir}/usr/"

tar --owner=0 --group=0 -czf "${creation_dir}/data.tar.gz" -C "${data_creation_dir}/" .

# Finishing touches

echo "2.0" > "${creation_dir}/debian-binary"

# Bundle everything

ar r "git-hash-select_${version}_all.deb" "${creation_dir}/debian-binary" "${creation_dir}/control.tar.gz" "${creation_dir}/data.tar.gz"
