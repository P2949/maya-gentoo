#!/usr/bin/env bash
set -euo pipefail

# Import an official Autodesk Maya Linux outer archive into Portage DISTDIR.
# This script never installs RPMs and never commits proprietary payloads.

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
release_file="$repo_root/releases/2027.2/release.json"
usage() { printf 'Usage: %s [--inspect] OFFICIAL_MAYA_INSTALLER\n' "$0" >&2; exit 2; }
inspect=0
if [[ ${1:-} == --inspect ]]; then inspect=1; shift; fi
[[ $# -eq 1 ]] || usage
input=$1
[[ -f $input ]] || { printf 'not a regular file: %s\n' "$input" >&2; exit 1; }

expected_hash=$(awk -F'"' '/archive_sha256/{print $4}' "$release_file")
actual_hash=$(sha256sum "$input" | awk '{print $1}')
if [[ $inspect -eq 0 && $actual_hash != "$expected_hash" ]]; then
  printf 'unsupported or mismatched archive; expected SHA-256 %s\n' "$expected_hash" >&2
  printf 'use --inspect only for maintainer analysis of a future release\n' >&2
  exit 1
fi

work_root=${MAYA_IMPORT_ROOT:-$(mktemp -d /tmp/native-maya-import.XXXXXX)}
cleanup() { [[ -z ${MAYA_IMPORT_ROOT:-} ]] && rm -rf -- "$work_root"; }
trap cleanup EXIT
mkdir -p "$work_root/extracted"

magic=$(file -b "$input")
case "$magic" in
  *RPM*|*Zip*|*7-zip*|*gzip*|*XZ*|*tar*) ;;
  *) printf 'refusing unrecognized archive: %s\n' "$magic" >&2; exit 1;;
esac

extract_dir=$work_root/extracted
case "$input" in
  *.rpm) rpm2cpio "$input" | (cd "$extract_dir" && cpio -idm --quiet) ;;
  *.zip|*.ZIP) unzip -q "$input" -d "$extract_dir" ;;
  *.tar|*.tar.*|*.tgz) tar -xf "$input" -C "$extract_dir" ;;
  *) 7z x -y -o"$extract_dir" "$input" >/dev/null ;;
esac

map_file=${MAYA_IMPORT_MAP:-$work_root/component-map.tsv}
printf 'kind\tpath\tsha256\tsize\n' > "$map_file"
find "$extract_dir" -type f \( -iname '*.rpm' -o -iname '*.zip' -o -iname '*.tgz' -o -iname '*.tar.gz' \) -print0 |
while IFS= read -r -d '' item; do
  rel=${item#"$extract_dir"/}
  kind=optional
  name=${rel##*/}
  case "$name" in
    *[Mm]aya*.rpm) kind=maya;;
    *[Ll]icens*.rpm|*adsklic*.rpm) kind=licensing;;
    *[Ii]dentity*.rpm|*adskidentity*.rpm) kind=identity;;
    *[Aa]dp*.zip) kind=adp-sdk;;
    *[Aa]rnold*.rpm|*MtoA*.rpm) kind=arnold;;
  esac
  hash=$(sha256sum "$item" | awk '{print $1}')
  size=$(stat -c '%s' "$item")
  printf '%s\t%s\t%s\t%s\n' "$kind" "$rel" "$hash" "$size" >> "$map_file"
done

grep -E $'^(maya|licensing|identity|adp-sdk)\t' "$map_file" >/dev/null || {
  printf 'no required Autodesk component family found; refusing import\n' >&2; exit 1;
}

if [[ $inspect -eq 1 ]]; then
  cat "$map_file"
  printf 'inspection only; no distfiles installed\n'
  exit 0
fi

distdir=${DISTDIR:-$(portageq envvar DISTDIR)}
[[ -n $distdir ]] || { printf 'Portage DISTDIR is empty\n' >&2; exit 1; }
mkdir -p "$distdir"
while IFS=$'\t' read -r kind rel hash size; do
  [[ $kind == kind ]] && continue
  src=$extract_dir/$rel
  dst=$distdir/${rel##*/}
  if [[ -e $dst ]]; then
    existing=$(sha256sum "$dst" | awk '{print $1}')
    [[ $existing == "$hash" ]] || { printf 'refusing to overwrite differing distfile: %s\n' "$dst" >&2; exit 1; }
  else
    install -m 0644 "$src" "$dst"
  fi
done < "$map_file"


printf '%s\n' "$map_file"
cat "$map_file"
