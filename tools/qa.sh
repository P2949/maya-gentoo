#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd -P -- "$(dirname -- "$0")/.." && pwd)
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
  pkgcheck scan --net none acct-group acct-user app-autodesk media-gfx --exit error || fail=1
fi
[[ -z $(git ls-files '*.rpm' '*.tgz' '*.zip' '*.tar.gz') ]] || { echo 'proprietary payload tracked' >&2; fail=1; }
while IFS= read -r -d '' cache; do
  rel=${cache#metadata/md5-cache/}
  category=${rel%%/*}
  cpv=${rel#*/}
  pkg=${cpv%-*}
  [[ -n $(find "$category" -type f -name "${pkg}-*.ebuild" -print -quit 2>/dev/null) ]] || {
    echo "orphan metadata cache entry: $cache" >&2
    fail=1
  }
done < <(find metadata/md5-cache -type f -print0)
if git grep -n -E '/home/p2949|DISPLAY=:0|overlay-worktree|/var/db/repos/local-autodesk' -- \
  ':!tools/qa.sh' ':!MAYA_GENTOO_REPOSITORY_AUTONOMOUS_PLAN.md' \
  ':!NATIVE_MAYA_GENTOO_AUTONOMOUS_PLAN.md' ':!docs/development/legacy-handoff.md'; then
  echo 'machine-specific path found in portable repository content' >&2; fail=1
fi
exit "$fail"
