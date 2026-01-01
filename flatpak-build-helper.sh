#!/usr/bin/env bash

set -uexo pipefail

which flatpak
which flatpak-builder

flatpak-builder --disable-rofiles-fuse --install-deps-from=flathub --repo=repo build $flatpak_id/$flatpak_id.yml
flatpak build-bundle repo $flatpak_name-$runner_arch.flatpak $flatpak_id

