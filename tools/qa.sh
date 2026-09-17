#!/usr/bin/env bash
set -euo pipefail
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"
fail=0
while IFS= read -r -d '' f; do bash -n "$f" || fail=1; done < <(find . -type f -name '*.sh' -print0)
if command -v shellcheck >/dev/null; then shellcheck tools/*.sh || fail=1; fi
if command -v xmllint >/dev/null; then
  while IFS= read -r -d '' f; do xmllint --noout "$f" || fail=1; done < <(find . -type f -name metadata.xml -print0)
fi
if command -v pkgcheck >/dev/null; then
  # Scan only Gentoo category trees; docs, tools, and release metadata are not
  # package categories and otherwise produce UnknownCategoryDirs noise.
  pkgcheck scan --net none acct-group acct-user app-autodesk media-gfx || fail=1
fi
[[ -z $(git ls-files '*.rpm' '*.tgz' '*.zip' '*.tar.gz') ]] || { echo 'proprietary payload tracked' >&2; fail=1; }
if git grep -n -E '/home/p2949|DISPLAY=:0|overlay-worktree|/var/db/repos/local-autodesk' -- \
  ':!tools/qa.sh' ':!MAYA_GENTOO_REPOSITORY_AUTONOMOUS_PLAN.md' \
  ':!MAYA_GENTOO_HANDOFF.md' ':!NATIVE_MAYA_GENTOO_AUTONOMOUS_PLAN.md'; then
  echo 'machine-specific path found in portable repository content' >&2; fail=1
fi
exit "$fail"
