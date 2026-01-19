#!/usr/bin/env bash

set -uexo pipefail

# clean some bloat to free some space
sudo rm -rf \
  /usr/share/dotnet \
  /usr/local/share/dotnet \
  /opt/hostedtoolcache/dotnet \
  /usr/local/lib/android \
  /usr/local/share/android \
  /usr/local/android-sdk \
  /opt/android \
  /opt/ghc \
  /usr/local/.ghcup \
  /opt/hostedtoolcache/CodeQL \
  /opt/hostedtoolcache/CodeQL* \
  /usr/local/lib/codeql \
  /opt/codeql

# prerequisites
sudo apt update
sudo apt install -y linux-modules-extra-$(uname -r)
sudo podman pull ghcr.io/flathub-infra/flatpak-github-actions:freedesktop-25.08

# clone manifest repo
if [ -n "$repo_url" ]; then
  git clone $repo_url $flatpak_id
else
  git clone https://github.com/$repository_owner/$flatpak_id
fi

# enable 32 gb zram
sudo modprobe zram
dev=$(sudo zramctl --find --algorithm zstd --size 32G)
sudo mkswap $dev
sudo swapon --priority 100 $dev

# run build
sudo podman run --privileged \
  --env=runner_arch=$runner_arch \
  --env=flatpak_id=$flatpak_id \
  --env=flatpak_name=$flatpak_name \
  --env=type=$type \
  --env=branch=$branch \
  -v $PWD:/build:z \
  -w /build \
  ghcr.io/flathub-infra/flatpak-github-actions:freedesktop-25.08 \
  /build/scripts/build-perform.sh
