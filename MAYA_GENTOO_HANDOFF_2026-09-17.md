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
2. `media-gfx/maya-2027.2-r1` is recorded in the VDB with repository
   `maya-gentoo`.
3. `media-gfx/maya-2027.2-r1` was re-emerged from `::maya-gentoo`; the
   revision carries the launcher/runtime corrections made after the original
   `2027.2` publication.
4. `app-autodesk/adsk-identity-manager-1.18.1.2-r1` was re-emerged from
   `::maya-gentoo` and records `maya-gentoo` in its VDB.
5. `app-autodesk/adp-desktop-sdk-6.3.34` records `maya-gentoo` in its VDB.
6. The OpenRC `adsklicensing` service is started.
7. `AdskLicensingInstHelper` reports Maya feature `MAYA`, product key `657S1`,
   and `authorize_succ: true`.
8. `mayapy` standalone startup succeeds.
9. Maya batch mode returns `2027`.
10. Xwayland is available with direct accelerated Mesa GLX rendering and
   OpenGL 4.6 on the AMD Radeon test GPU.
11. The known GUI startup crash fix is present: Maya is launched through the
   XCB-scoped wrapper and its private empty `libmd.so` compatibility file is
   installed.

The GUI/license success was also observed interactively after Autodesk
authentication. Arnold is intentionally not claimed because it was absent
from the tested Autodesk payload.

## Closure results and remaining host diagnostic

Identity Manager revision `1.18.1.2-r1` eliminates the package-external
WebKitGTK compatibility links. Inspection of the actual RPM found exactly one
consumer of the obsolete SONAMEs: `libIdServicesCore.so`. The ebuild uses
`dev-util/patchelf` in `src_prepare()` to replace
`libwebkit2gtk-4.0.so.37` with `libwebkit2gtk-4.1.so.0` and
`libjavascriptcoregtk-4.0.so.18` with `libjavascriptcoregtk-4.1.so.0`.
The RPM tree is installed with `cp -a` so executable modes and bundled links
are preserved.

The staged test, Portage `src_prepare`, installed `ldd` resolution, and a
bounded Identity Manager launch passed. The installed package contains no
WebKit compatibility symlinks, and the patched library resolves to the real
4.1 libraries. The old `local-autodesk` Identity Manager and Maya instances
were removed during the revisioned merge. Their removal phases emitted the
optimization framework's cross-generation diagnostic because the framework
generation changed while replacing old VDB entries, but the new packages
merged successfully and passed the package-image ABI guard. This is host
framework housekeeping, not an Identity Manager external-SONAME failure.

`profiles/eapi` now declares repository EAPI 8, and `metadata/layout.conf`
contains only repository-layout settings. No optimization exclusion, global
policy change, kernel, bootloader, EFI/NVRAM, or boot-partition mutation was
used.

Manifests and metadata caches were regenerated for the new Identity Manager
and Maya revisions. `tools/qa.sh` passes its repository checks; `pkgcheck` still
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

## Public-overlay hardening pass

The public install path now documents scoped `~amd64` keyword and
`all-rights-reserved` licence acceptance, calls `emerge --config
media-gfx/maya`, and provides the user-level `adsk-identity-register` helper.
That helper runs Autodesk's `--register`, creates or normalizes
`com.autodesk.AdskIdentityManager.desktop`, refreshes the desktop database when
available, and associates `x-scheme-handler/adskidmgr` without performing
per-user setup from an ebuild. A clean temporary Unix-user test verified the
desktop file and MIME association; the upstream registration subprocess still
requires a real desktop secret-service/session environment and reports that
failure explicitly.

The superseded unrevisioned Maya and Identity Manager ebuilds were removed.
The `adsklic` account packages use dynamic IDs in revisioned `-r1` ebuilds.
The importer now requires every family listed in `release.json`, stages final
DISTDIR copies before a narrowly scoped writable-directory/doas step, and
fails Bifrost installation when required payload directories are absent.
Proprietary Autodesk packages carry `bindist` restrictions, and Autodesk CER
state directories use sticky `1777` permissions. Metadata contacts and the
Portage guide were refreshed.

The current workstation's Portage configuration is owned by the separate
optimization framework and currently omits a `maya-gentoo` repos.conf entry;
`tools/preflight.sh` therefore fails its repository-registration gate on this
host until the administrator registers the overlay in the active Portage
configuration. This pass did not mutate that framework-owned configuration.

The live authenticated desktop test also showed that Autodesk's
`AdskIdentityManager --register` can remain resident without returning. The
helper now bounds that subprocess to 30 seconds, installs the callback before
reporting the timeout, and returns status 124 with an explicit diagnostic;
this prevents a hung registration process from blocking the user's shell.
