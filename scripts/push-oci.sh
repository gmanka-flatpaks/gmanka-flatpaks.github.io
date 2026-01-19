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

git config --global user.name gmanka-flatpaks
git config --global user.email 41898282+github-actions[bot]@users.noreply.github.com
gh auth setup-git
git clone https://github.com/gmanka-flatpaks/state
cd state
git switch -c update-$flatpak_id-$commit
yq -i '.[strenv(flatpak_id)] = strenv(commit)' state.yml
git add --all
git commit -m "[u] update $flatpak_id to $commit"
git push -f origin HEAD
pr=$(gh pr create --fill)
gh pr merge --rebase --delete-branch $pr
