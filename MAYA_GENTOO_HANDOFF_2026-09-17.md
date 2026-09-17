# Maya Gentoo handoff — 2026-09-17

This file records the current state of the native Autodesk Maya Gentoo
repository work. It is an operational handoff, not a replacement for the
controlling specification in
[`MAYA_GENTOO_REPOSITORY_AUTONOMOUS_PLAN.md`](MAYA_GENTOO_REPOSITORY_AUTONOMOUS_PLAN.md).

## Repository state

- Repository: `maya-gentoo`
- Public origin: `https://github.com/P2949/maya-gentoo.git`
- Working checkout: the project directory containing this file
- Live Portage checkout: `/var/db/repos/maya-gentoo`
- Repository identity is set in `metadata/layout.conf` and
  `profiles/repo_name`.
- The old `local-autodesk` Portage configuration was disabled reversibly as
  `local-autodesk.conf.disabled`; the old overlay files were not deleted.
- No proprietary archive, extracted RPM, credential, token, or license data is
  tracked in Git.

## Implemented repository contents

The checkout now contains the reusable package implementation for:

- `app-autodesk/adp-desktop-sdk`
- `app-autodesk/adsk-identity-manager`
- `app-autodesk/adsk-licensing`
- `media-gfx/maya`
- `media-gfx/maya-usd`
- `media-gfx/bifrost`
- `media-gfx/lookdevx`
- `media-gfx/substance-maya`
- `acct-group/adsklic` and `acct-user/adsklic`

It also contains package metadata, repository metadata, release metadata for
Maya 2027.2 build 1839, the productized importer, preflight and installation
verification tools, QA tooling, installation/troubleshooting/compatibility
guides, maintainer notes, and development validation records.

## Import boundary

`tools/import-autodesk-payload.sh --inspect <official-archive>` successfully
classified the tested Maya 2027.2 archive without installing anything. The
release hash and component map are recorded in
`releases/2027.2/release.json`. Normal import requires the known archive hash,
uses Portage's configured `DISTDIR`, refuses conflicting distfiles, and never
writes proprietary payloads into the repository.

## Functional validation completed

The following checks passed on the target Gentoo host:

1. `portageq get_repo_path / maya-gentoo` resolves to the new live checkout.
2. `media-gfx/maya-2027.2` is recorded in the VDB with repository
   `maya-gentoo`.
3. `media-gfx/maya-2027.2` was re-emerged from `::maya-gentoo`.
4. The OpenRC `adsklicensing` service is started.
5. `AdskLicensingInstHelper` reports Maya feature `MAYA`, product key `657S1`,
   and `authorize_succ: true`.
6. `mayapy` standalone startup succeeds.
7. Maya batch mode returns `2027`.
8. Xwayland is available with direct accelerated Mesa GLX rendering and
   OpenGL 4.6 on the AMD Radeon test GPU.
9. The known GUI startup crash fix is present: Maya is launched through the
   XCB-scoped wrapper and its private empty `libmd.so` compatibility file is
   installed.

The GUI/license success was also observed interactively after Autodesk
authentication. Arnold is intentionally not claimed because it was absent
from the tested Autodesk payload.

## Known incomplete items and evidence

Two installed components still retain the old VDB repository label:

- `app-autodesk/adp-desktop-sdk-6.3.34`
- `app-autodesk/adsk-identity-manager-1.18.1.2`

The attempted rebuild from `::maya-gentoo` was blocked by the host's strict
system-wide optimization policy. The identity package contains Autodesk's
external absolute symlinks, which the policy rejects during QA, and removal of
old-overlay instances can cross optimization framework generations. The
licensing package and all tested Maya/optional component packages did migrate
to `maya-gentoo`; the failed packages remain installed and functional from the
previous build. No optimization policy, kernel, bootloader, EFI/NVRAM, or
system-wide package configuration was weakened to bypass this blocker.

The package Manifest was regenerated after the repository-only ADP ebuild
metadata change. `tools/qa.sh` passes its repository checks; `pkgcheck` still
prints non-fatal vendor-package warnings for Autodesk/Adobe URL access,
absolute vendor symlinks, legacy dependencies, and formatting inherited from
the working ebuilds. These are documented implementation warnings rather than
hidden failures.

## Resume procedure

From the repository checkout:

```sh
bash tools/preflight.sh
bash tools/qa.sh
bash tools/verify-install.sh
git status --short --branch
```

Before any final completion claim, inspect the controlling plan's remaining
criteria, regenerate the live repository copy after any edits, verify all
package VDB `repository` files, run the clean re-emerge/validation criteria,
review Git history for secrets and payloads, commit, and push if the origin is
writable. Preserve the disabled old-repository configuration as a recoverable
backup. Do not touch boot entries, EFI/NVRAM, kernels, initramfs, bootloaders,
or boot partitions.
