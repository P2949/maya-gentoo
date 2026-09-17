#!/usr/bin/env bash
set -euo pipefail
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
printf 'repository: %s\n' "$repo_root"
command -v emerge >/dev/null || { echo 'Portage emerge is required' >&2; exit 1; }
command -v portageq >/dev/null || { echo 'Portage portageq is required' >&2; exit 1; }
portageq get_repo_path / maya-gentoo || { echo 'maya-gentoo is not registered with Portage' >&2; exit 1; }
printf 'architecture: '; uname -m
printf 'init: '; if [[ -d /run/openrc ]]; then echo OpenRC; elif [[ -d /run/systemd/system ]]; then echo systemd; else echo unknown; fi
printf 'DISTDIR: '; portageq envvar DISTDIR
command -v Xwayland >/dev/null && echo 'Xwayland: available' || echo 'Xwayland: not found'
command -v glxinfo >/dev/null && glxinfo -B 2>/dev/null | sed -n '1,20p' || echo 'glxinfo: not available'
echo 'Preflight checks completed.'
