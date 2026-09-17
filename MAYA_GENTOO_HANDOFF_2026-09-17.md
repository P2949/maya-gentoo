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
- The completeness audit found no missing Autodesk-specific compatibility
  ebuilds in the old overlay. TIFF, libxml2, OpenSSL, and MIT Kerberos ABI
  providers are Gentoo packages; Maya now declares the compatibility/runtime
  providers it actually loads (`media-libs/tiff-compat`,
  `dev-libs/libxml2-compat`, `dev-libs/openssl-compat`, and
  `app-crypt/mit-krb5`).
- The three historical CA paths were unowned host artifacts. They contain the
  same bytes as Gentoo's maintained CA bundle on this host. The Maya wrapper
  now selects a readable CA path dynamically and does not require those
  compatibility paths to be created by the overlay.

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

One installed component still retains the old VDB repository label:

- `app-autodesk/adsk-identity-manager-1.18.1.2`

ADP Desktop SDK now re-emerges successfully from `::maya-gentoo`. Identity
Manager's package source was corrected to EAPI-8 relative `dosym` calls, but
the host ABI guard intentionally rejects the resulting symlinks because they
resolve outside the staged package tree. The separate optimization framework
currently has no production parser/schema for package exclusions: its
`exclusions.yaml` and `package-overrides.yaml` are intentionally empty and
its policy tests enforce that baseline. No unsupported exclusion format,
optimization bypass, kernel, bootloader, EFI/NVRAM, or system-wide policy
weakening was introduced. Maya, licensing, ADP, and all tested optional
component packages are now owned by `maya-gentoo`; Identity Manager remains
functional from its previous installed instance.

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
