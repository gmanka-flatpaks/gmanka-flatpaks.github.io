#!/usr/bin/env bash

set -uexo pipefail

sudo apt update
sudo apt install -y flatpak ostree
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0

ostree init --mode=archive-z2 --repo repo
podman manifest create app
for arch in x86_64 aarch64; do
  [ -d artifacts/$flatpak_name-$arch ] || continue
  flatpak build-import-bundle repo artifacts/$flatpak_name-$arch/$flatpak_name-$arch.flatpak
  flatpak build-bundle --oci repo oci $type/$flatpak_id/$arch/$branch
  skopeo copy oci:oci:$type/$flatpak_id/$arch/$branch containers-storage:app:$arch
  podman manifest add app containers-storage:app:$arch
done
podman login quay.io -u gmankab -p $quay_token
podman manifest push --all app docker://quay.io/gmanka/$flatpak_name:latest
