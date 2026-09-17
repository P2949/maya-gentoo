# AUTONOMOUS EXECUTION PLAN — Native Autodesk Maya 2027.x on Gentoo

## 0. Controlling objective

Install Autodesk Maya natively on the existing Gentoo host and leave it in a maintainable, Portage-managed state.

For this plan, **native** means all of the following:

- no Docker, Podman, Distrobox, container, chroot, FHS compatibility environment, VM, Flatpak, Snap, or alternate userspace;
- Maya executes directly as a host Gentoo process;
- Maya uses the host kernel, amdgpu, Mesa/radeonsi, filesystem, desktop session, audio stack, and ordinary user home;
- Autodesk application files are owned by Portage packages wherever technically practical;
- Autodesk RPMs are treated as upstream source archives and are **never installed into a Gentoo RPM database**;
- compatibility libraries needed only by Autodesk software are isolated under an Autodesk-private prefix rather than changing the host globally;
- the existing Gentoo compiler/toolchain, libc++ policy, Mesa stack, OpenSSL, LLVM, kernel, and graphics configuration are not redesigned around Maya.

The currently intended release is **Maya 2027.2**. Before doing package work, verify from Autodesk's official current release information whether a newer Maya 2027.x update has superseded 2027.2. If a newer 2027.x update is both officially available and obtainable using the same account/payload flow, use it and adapt all versions from the actual payload. Never copy old product keys, RPM filenames, SDK versions, or package release numbers from this document.

Autodesk supports RHEL/Rocky rather than Gentoo. This is intentionally an unsupported native packaging project. Do not represent it as vendor-supported.

---

# 1. Execution mode: maximum autonomy

This is an **execution specification**, not a checklist to discuss with the user.

The implementing agent MUST:

1. read this entire file before making changes;
2. inspect the actual host and actual Autodesk payload instead of asking the user for information that can be discovered;
3. research current Autodesk, Gentoo, and native-Arch packaging details itself when needed;
4. make routine technical decisions itself;
5. create, edit, build, install, debug, retry, and validate autonomously;
6. preserve a resumable state file and logs;
7. continue through failures by diagnosis and repair rather than asking what to do next;
8. never ask “should I continue?”, “do you want me to…?”, “which option do you prefer?”, or equivalent;
9. never request confirmation for routine package installation, overlay creation, scoped configuration, service setup, MIME registration, testing, or corrective work that is allowed by this plan;
10. stop for a human only at an explicit HUMAN INTERVENTION GATE defined below.

If an assumption in this file conflicts with the actual current Autodesk payload or current authoritative documentation, follow the current payload/documentation while preserving the architectural constraints of this file.

The target is a working installation, not merely a report.

---

# 2. HUMAN INTERVENTION GATES — the only permitted pauses

There are only three classes of human intervention.

## Gate H1 — privileged authentication that cannot be performed noninteractively

First test whether privileged commands work without interaction:

```bash
doas -n true
```

If that succeeds, use `doas -n`/normal `doas` as appropriate and do not ask the user anything.

If privileged access requires an interactive terminal password, request exactly one action:

> HUMAN ACTION REQUIRED — privilege authentication: enter your administrator password directly into the active terminal prompt. Do not send the password in chat. I will continue automatically afterwards.

Never ask the user to reveal a password.

Batch privileged operations sensibly while authentication is valid. Do not edit `doas.conf`, weaken sudo/doas policy, enable NOPASSWD, or otherwise change security policy merely to avoid this gate.

If privilege expires later and another terminal authentication is genuinely necessary, the same gate may be used again, but do not ask any unrelated question.

## Gate H2 — Autodesk account authentication, MFA, consent, or licence/EULA action

The agent must attempt the Autodesk account/download/login flow itself using the available browser/computer environment.

If Autodesk requires credentials, MFA, account selection, explicit terms acceptance, or another action that must legally/security-wise be performed by the account holder, request exactly the required interaction:

> HUMAN ACTION REQUIRED — Autodesk account: complete the sign-in/MFA/required Autodesk consent in the window I opened. Do not send credentials or tokens in chat. I will detect completion and continue automatically.

After presenting this gate, poll/detect completion where possible. Do not require the user to type “continue” or restate the goal.

The agent must never accept a new legal agreement on the user's behalf when explicit user acceptance is required.

## Gate H3 — proprietary Autodesk payload cannot be obtained by the agent

Before invoking this gate, the agent MUST:

- search the user's normal download locations and the work environment;
- search Portage DISTDIR;
- inspect existing files for the correct official Maya installer;
- attempt the official Autodesk account/download path using the current authenticated browser session if computer/browser access exists;
- use H2 if Autodesk authentication is the blocker.

Only if the agent still cannot obtain the official installer because the environment cannot perform the download itself may it request:

> HUMAN ACTION REQUIRED — Autodesk payload: download the official Linux installer for the target Maya 2027.x release from your Autodesk account and place the downloaded file in `~/Downloads/`. Do not unpack or rename it. I am monitoring that directory and will continue automatically when it appears.

The agent should then poll for the file and resume automatically.

Do not ask the user to manually download individual RPMs, identify package names, unpack the archive, calculate hashes, copy files to DISTDIR, or provide product registration values. Those are agent tasks.

---

# 3. What is NOT a reason to ask the human

The following are agent responsibilities and must never trigger a clarification request:

- determining whether the host uses OpenRC or systemd;
- determining the desktop compositor/session type;
- determining whether XWayland is installed;
- finding Mesa, OpenGL, X11/XCB, WebKitGTK, GTK, libffi, OpenSSL, GCC runtime, or other Gentoo package names;
- discovering Portage DISTDIR;
- creating the overlay;
- choosing ebuild package versions from actual RPM metadata;
- inspecting RPM scripts;
- choosing package splits;
- choosing safe compatibility-library sources;
- translating a systemd unit to OpenRC;
- registering desktop MIME handlers for the current user;
- setting Maya-only X11/XWayland environment variables;
- solving ELF dependency failures;
- deciding whether a library should come from Maya, Gentoo, Autodesk-private compatibility files, or a trusted compatibility RPM;
- writing ebuilds;
- fixing manifests;
- fixing pkgcheck/pkgdev issues;
- performing Portage dry-runs;
- running `emerge`;
- starting/enabling Autodesk services;
- registering Maya with `AdskLicensingInstHelper`;
- debugging status 255;
- debugging Identity Manager callback failures;
- debugging Application Home;
- debugging Viewport 2.0;
- testing mayapy;
- testing scene creation/save/reopen;
- packaging Arnold, MayaUSD, Bifrost, LookdevX, or Substance;
- reverting a failed scoped change and trying another solution.

If a choice has multiple viable implementations, choose the one that best satisfies, in order:

1. host integrity;
2. ABI correctness;
3. Portage ownership/reproducibility;
4. current Autodesk behavior;
5. minimum invasive changes;
6. maintainability;
7. simplicity.

---

# 4. Non-negotiable host-integrity rules

Do not solve Maya compatibility by globally modifying the Gentoo platform.

Forbidden:

```text
downgrading glibc
downgrading system OpenSSL
changing the global C++ standard library
changing the default system compiler
changing the system C++ ABI
replacing Mesa
installing AMDGPU-PRO
installing amdgpu-dkms
changing the kernel for Maya
changing global LLVM configuration
installing Autodesk RPMs with rpm -i/-U
creating fake SONAME symlinks in /usr/lib or /usr/lib64
copying foreign libraries directly into /usr/lib*
setting a global LD_LIBRARY_PATH
adding Maya libraries to /etc/ld.so.conf unless an Autodesk-specific,
well-justified path is demonstrably required and no scoped alternative exists
modifying /etc/environment for Maya
modifying shell startup files for Maya
replacing Gentoo Qt globally
replacing Gentoo Python globally
disabling Portage collision protection
using rpm --force
using cp --force to overwrite Portage-owned files
changing unrelated global USE flags
performing an unrelated world upgrade
```

Allowed scoped changes include:

```text
creating /var/db/repos/local-autodesk
adding its repos.conf entry
installing required Gentoo runtime/build tools through Portage
adding narrowly scoped package.use/package.accept_keywords entries when
necessary for new Maya dependencies and when they do not destabilize existing software
creating Autodesk-specific account packages if the payload requires them
installing Autodesk service definitions
creating /opt/Autodesk/compat
creating Maya/Identity-Manager-only wrappers
creating Maya desktop entries
creating per-user adskidmgr MIME association
```

Before modifying an existing file under `/etc/portage`, preserve its current content in the run backup directory. Prefer new dedicated files such as:

```text
/etc/portage/repos.conf/local-autodesk.conf
/etc/portage/package.use/maya-native
/etc/portage/package.accept_keywords/maya-native
```

rather than editing unrelated existing files.

If Portage proposes removal/replacement/downgrade of core platform components to satisfy Maya, reject that solution automatically and use an Autodesk-private compatibility approach instead.

---

# 5. Sources of truth

Use sources in this order.

## 5.1 Actual Autodesk payload

The official installer/archive obtained from the user's Autodesk account is authoritative for:

- component names;
- exact versions;
- filesystem layout;
- product registration files;
- PIT/config files;
- RPM scripts;
- service units;
- Identity Manager;
- ADP Desktop SDK;
- optional components.

## 5.2 Current Autodesk documentation

Research current documentation as needed, especially:

- Maya 2027.x release notes;
- supported Linux requirements;
- RPM installation;
- Autodesk Licensing;
- Identity Manager;
- ADP Desktop SDK;
- Maya 2027 status-255/AdpSDKCore.so issue;
- component compatibility matrices.

Known relevant references at plan creation time:

```text
https://help.autodesk.com/cloudhelp/2027/ENU/Maya-ReleaseNotes/files/MAYA_RELEASENOTES_2027_2_HTML.html

https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Maya-2027-silently-exits-with-status-255-on-a-headless-Linux-render-node-before-the-license-check.html

https://help.autodesk.com/cloudhelp/2025/ENU/Maya-Installlation/files/GUID-E7E054E1-0E32-4B3C-88F9-BF820EB45BE5.htm
```

Use newer/current pages if Autodesk has superseded these.

## 5.3 Current native Arch packaging

Use the maintained AUR packages as a reference for how current Maya is made to work natively on a modern rolling non-RHEL system.

Attempt source retrieval autonomously using git, for example:

```bash
git clone https://aur.archlinux.org/maya.git
```

and similarly for current packages corresponding to:

```text
maya
adsklicensing
adskidentitymanager
adp-desktop-sdk
maya-arnold
maya-bifrost
maya-usd-bin
maya-lookdevx
maya-substance
```

If AUR HTTP pages are blocked by Anubis, prefer the git endpoint rather than asking the user.

Do not install pacman or makepkg.

Do not copy Arch package names directly into Gentoo dependencies.

## 5.4 Gentoo policy and current tree

Use current Gentoo eclass/devmanual documentation and the live Gentoo repository as authority for ebuild mechanics.

At plan creation time, `rpm.eclass` supports EAPI 8 and is specifically intended for extracting RPM sources. Re-check the installed/current eclass before authoring the package.

Prefer current Gentoo examples for:

- fetch-restricted proprietary packages;
- `rpm.eclass`;
- `systemd.eclass`;
- OpenRC init scripts;
- `xdg.eclass`/desktop integration;
- `acct-user.eclass`;
- `acct-group.eclass`;
- prebuilt binary QA handling;
- local repository layout.

---

# 6. Persistent autonomous run state

Create:

```text
~/src/native-maya-gentoo/
├── STATE.md
├── DECISIONS.md
├── research/
├── payload/
├── staging/
├── logs/
├── backups/
├── scripts/
└── overlay-worktree/
```

`STATE.md` must always contain:

```text
target Maya version/build
current phase
completed phases
current blocker, if any
last successful command
next autonomous action
human intervention gate currently active, if any
overlay git commit
installed Autodesk package versions
```

Update it after every major phase and immediately before any HUMAN INTERVENTION GATE.

`DECISIONS.md` must record non-obvious compatibility decisions, including:

```text
problem
evidence
chosen solution
rejected alternatives
affected package/path
whether workaround is temporary
```

This ensures that after authentication or a tool/session interruption the agent resumes from state rather than asking the user to restate anything.

---

# 7. Phase A — baseline host discovery

Perform this autonomously before modifying the system.

Create the work tree and capture:

```bash
uname -a
cat /etc/gentoo-release
eselect profile show
emerge --info
gcc-config -l || true
clang --version || true
ldd --version
readlink -f /usr/bin/cc || true
readlink -f /usr/bin/c++ || true
portageq get_repo_path / gentoo
portageq envvar DISTDIR
portageq envvar PORTDIR
```

Detect init system from PID 1 and available service tools.

Detect desktop state:

```bash
printf 'XDG_SESSION_TYPE=%s\n' "$XDG_SESSION_TYPE"
printf 'WAYLAND_DISPLAY=%s\n' "$WAYLAND_DISPLAY"
printf 'DISPLAY=%s\n' "$DISPLAY"
command -v Xwayland || true
```

Detect graphics:

```bash
lspci -k | grep -EA4 'VGA|Display|3D' || true
glxinfo -B 2>/dev/null || true
eglinfo 2>/dev/null | head -150 || true
```

Inventory available C++ runtimes:

```bash
find /usr/lib /usr/lib64 /usr/lib/gcc \
    \( -name 'libstdc++.so*' -o -name 'libgcc_s.so*' \) \
    -print 2>/dev/null
```

Record baseline hashes/content for any existing files that may later be touched under `/etc/portage`.

Install missing inspection/build tools through Portage without asking if their dry-run is non-destructive. Likely useful tools include:

```text
app-arch/rpm
app-misc/pax-utils
app-portage/gentoolkit
app-portage/pkgcheck
dev-util/pkgdev
dev-debug/strace
media-libs/mesa-progs or package providing glxinfo
```

Discover exact current atoms rather than assuming this list is still exact.

Do not install a tool merely because it is listed if an equivalent is already present.

---

# 8. Phase B — autonomously acquire the official Maya payload

Search first:

```text
~/Downloads
~/download
~/Downloads/Autodesk
the current work environment
Portage DISTDIR
~/src/native-maya-gentoo/payload
```

Use file magic, archive listing, RPM metadata, filenames, and content to identify candidates.

Do not trust a filename alone.

If absent, use available browser/computer/web capability to navigate to Autodesk's official account/download area and obtain the current official Maya 2027.x Linux installer.

Use H2 only for account/MFA/EULA interaction.

Use H3 only if the environment cannot itself perform the final download.

Once obtained:

1. preserve the original installer unchanged;
2. calculate SHA256;
3. record source path and hash;
4. extract as the normal user into staging;
5. inventory all files;
6. identify required and optional Autodesk components.

Expected component families include, but are not limited to:

```text
Maya RPM
Autodesk Licensing RPM(s)
Autodesk Identity Manager RPM
ADP Desktop SDK ZIP
PIT/config files
FlexNet/licensing auxiliaries
Arnold
MayaUSD
Bifrost
LookdevX
Substance
desktop/service metadata
```

Do not assume exact filenames.

---

# 9. Phase C — create an automatic payload importer

Reduce future human intervention to a single official Maya installer.

Create a repository helper such as:

```text
tools/import-autodesk-payload.sh
```

Its job is to accept the official outer Maya installer/archive and:

1. verify it is an expected Autodesk Maya Linux package;
2. extract it to a temporary work tree;
3. discover exact component files;
4. copy the component RPM/ZIP/TGZ distfiles needed by the overlay into the live Portage `DISTDIR`;
5. preserve original upstream filenames when practical;
6. output SHA256 hashes;
7. emit a machine-readable component map;
8. refuse to overwrite a different existing distfile with the same name;
9. never install anything.

This script should make future rebuilds/updates require only the outer official installer rather than manual extraction of every Autodesk component.

Do not commit Autodesk payloads to git.

---

# 10. Phase D — inspect RPM/ZIP/install behavior

For every required RPM, record:

```bash
rpm -qip
rpm -qlp
rpm -qpR
rpm -qp --scripts
```

Extract and inspect:

- `%pre`;
- `%post`;
- `%preun`;
- `%postun`;
- systemd units;
- tmpfiles/sysusers files if present;
- desktop files;
- MIME/protocol handlers;
- symlinks;
- ownership/mode assumptions;
- registration commands;
- service users/groups;
- writable runtime paths.

Inspect ADP Desktop SDK ZIP structure.

Inspect Maya outer installer scripts for information not encoded in the RPM.

Save all observations to `logs/upstream-metadata/`.

This phase is specifically intended to prevent guessing about licensing/service behavior.

---

# 11. Phase E — inspect current AUR reference implementation

Clone current AUR package sources automatically.

Extract from them:

```text
payload mapping
dependencies
patches
file relocations
service handling
Identity Manager URI integration
Maya product registration
ADP SDK layout
Application Home workaround
Wayland/X11 workarounds
library search paths
optional component locations
```

Treat AUR as a reference, not authority.

For every nontrivial AUR workaround, classify it:

```text
required on Gentoo
not required on Gentoo
not yet known
```

Do not apply `not yet known` workarounds pre-emptively. Test first.

---

# 12. Phase F — create the local Gentoo overlay

Create:

```text
/var/db/repos/local-autodesk/
├── metadata/
│   └── layout.conf
├── profiles/
│   ├── repo_name
│   └── categories
├── licenses/
├── acct-group/          # only if required
├── acct-user/           # only if required
├── app-autodesk/
│   ├── adsk-licensing/
│   ├── adsk-identity-manager/
│   ├── adp-desktop-sdk/
│   └── autodesk-compat-libs/
├── media-gfx/
│   ├── maya/
│   ├── maya-arnold/
│   ├── maya-usd/
│   ├── maya-bifrost/
│   ├── maya-lookdevx/
│   └── maya-substance/
├── tools/
└── docs/
```

If `app-autodesk` is a custom category, ensure it is declared correctly in `profiles/categories`.

Set the repository master to Gentoo as appropriate.

Register it with a dedicated:

```text
/etc/portage/repos.conf/local-autodesk.conf
```

Initialize git in the overlay and commit coherent milestones.

Never commit:

```text
Autodesk RPMs
Autodesk ZIP/TGZ payloads
credentials
cookies
licence tokens
machine entitlement databases
```

---

# 13. Phase G — proprietary-source and licence handling

Use the current Gentoo canonical pattern for manually fetched/proprietary distfiles.

Do not blindly copy an obsolete `SRC_URI` example.

Inspect current Gentoo fetch-restricted packages and use the modern supported pattern.

Use appropriate:

```text
RESTRICT="fetch mirror strip"
```

or the minimum verified equivalent.

Derive package versions from upstream metadata.

If the Autodesk licence token used by the ebuild does not exist in the Gentoo master repository, create an appropriate local overlay licence entry using the licence text or reference supplied by Autodesk where legally appropriate.

Do not redistribute Autodesk payloads.

`pkg_nofetch()` should be a fallback for future manual use, but the autonomous run should use `import-autodesk-payload.sh` so the user is not asked to place every individual file manually.

---

# 14. Phase H — package Autodesk Licensing

This is a required component.

Create `app-autodesk/adsk-licensing` or a small set of licensing packages if the actual 2027.x payload clearly separates independently versioned required components.

Use `rpm.eclass` for RPM sources.

Preserve Autodesk's expected `/opt/Autodesk` and `/var/opt/Autodesk` hierarchy.

Reproduce required RPM script behavior through Gentoo package phases and service integration rather than executing RPM scripts blindly.

## Service account

If current payload creates an Autodesk service account, use proper local Gentoo:

```text
acct-group/<name>
acct-user/<name>
```

packages.

Do not hardcode an arbitrary UID/GID. Determine a valid local package account allocation according to current Gentoo account packaging rules.

If the current Autodesk release no longer needs a dedicated account, do not create one.

## systemd host

Install/adapt the actual current upstream unit with Gentoo's current systemd helpers.

Enable/start it after merge when appropriate.

## OpenRC host

Translate the **actual current Autodesk unit/service semantics** to a proper OpenRC init script.

Prefer `supervise-daemon` where suitable.

Preserve actual:

```text
command
arguments
user/group
working directory
environment
runtime directories
restart semantics
```

Do not invent the service from memory.

Enable it in the appropriate runlevel and start it.

## Gate

Do not proceed to Maya registration until:

```text
AdskLicensingInstHelper list
```

executes successfully and the service remains alive.

If the service fails, autonomously inspect logs, ELF dependencies, permissions, paths, and service environment and repair it.

---

# 15. Phase I — package Autodesk Identity Manager

Create:

```text
app-autodesk/adsk-identity-manager
```

from the exact supplied RPM.

Use its actual versioned layout under `/opt/Autodesk/AdskIdentityManager`.

Create `Current` only if required by current upstream behavior.

Map required WebKitGTK and other libraries to current Gentoo packages from actual ELF dependencies.

Install Autodesk's desktop/protocol integration.

Do not alter MIME association from the ebuild for arbitrary users.

After merge, as the current desktop user, query:

```bash
xdg-mime query default x-scheme-handler/adskidmgr
```

If missing/wrong, autonomously set the supplied Autodesk Identity Manager desktop entry as the current user's handler.

If Identity Manager requires X11 on this host, add a **scoped** launcher/desktop environment such as `GDK_BACKEND=x11` only after confirming it is needed.

No human prompt is needed for any of this.

---

# 16. Phase J — package ADP Desktop SDK

This is mandatory for Maya 2027.x.

Create:

```text
app-autodesk/adp-desktop-sdk
```

from the supplied:

```text
Packages/AdpSdk/adp-desktop-sdk.zip
```

or its current equivalent.

Install it under Autodesk's expected:

```text
/opt/Autodesk/AdpDesktopSDK/<version>
```

layout.

Create the expected stable `bin` path/symlink only if current Autodesk documentation/payload expects it.

Verify `AdpSDKCore.so` exists in the expected location.

Autodesk has documented Maya 2027/2027.2 exiting with status 255 before licensing when `AdpSDKCore.so` is unavailable. Therefore status 255 before a licence error must cause ADP SDK resolution to be checked first.

---

# 17. Phase K — build the Maya ELF dependency database

Before finalizing `media-gfx/maya` dependencies, unpack Maya to staging and build an objective dependency map.

Enumerate ELF objects using tools such as:

```bash
scanelf
readelf
objdump
lddtree
```

At minimum inspect:

```text
maya
maya.bin
mayapy
Render
Qt platform plug-ins
XGen
Application Home components
licensing-facing libraries
major bundled Maya plug-ins
```

Generate:

```text
logs/maya-needed-sonames.txt
logs/maya-library-map.tsv
logs/maya-unresolved.txt
```

For each dependency track:

```text
SONAME
requesting ELF
RPATH/RUNPATH
resolved file
source package
resolution class
```

Resolution classes:

```text
maya-bundled
autodesk-component
gentoo-system
autodesk-private-compat
unresolved
```

Do not flag optional dlopen targets as mandatory simply because a broad scan sees their filenames.

---

# 18. Phase L — autonomous library resolution policy

Resolve each required ABI in this priority order:

## L1 — Autodesk/Maya bundled library

If Maya intentionally ships a compatible library in its own supported search path, preserve and use it.

Do not replace bundled libraries merely because Gentoo has a newer copy.

## L2 — Gentoo system library

If current Gentoo supplies the exact compatible ABI cleanly, depend on that package.

Determine package ownership with tools such as:

```bash
qfile
equery belongs
equery files
pkg-config
ldconfig -p
```

Use `e-file`/PFL if available and useful.

## L3 — dedicated upstream compatibility package from Gentoo/upstream

If Gentoo provides a safe compatibility slot, use it.

If a runtime such as libstdc++ is available from the installed/current Gentoo GCC runtime and exports the required GLIBCXX symbols, use it even though the user's normal applications use libc++.

Do not change the user's default stdlib.

## L4 — Autodesk-private compatibility library from an authoritative source

If no safe Gentoo package exists, create/update:

```text
app-autodesk/autodesk-compat-libs
```

installing only the required compatibility ABI under:

```text
/opt/Autodesk/compat/lib64
```

Preferred provenance:

1. official upstream project source/binary where packaging is feasible;
2. a trusted official Rocky Linux 9.7 RPM providing the exact legacy runtime Autodesk targets, extracted only as source for the private compatibility package.

A Rocky RPM may be used as a **last-resort compatibility source** because Autodesk targets Rocky/RHEL userspace, but:

- never install the RPM into the host RPM database;
- extract only the required library/files;
- pin URL/version/hash;
- record provenance;
- keep files under `/opt/Autodesk/compat`;
- never allow them to replace host `/usr/lib*`;
- do not build a miniature Rocky root.

This fallback is specifically permitted to avoid unnecessary human intervention and global Gentoo downgrades.

## L5 — scoped wrapper/search-path adjustment

Expose private compatibility directories only to Autodesk processes.

## L6 — source/script patch

Patch Autodesk shell/python/desktop scripts only where necessary.

## L7 — binary patch

Binary `patchelf`/RPATH modification is a last resort. If needed, document exact reason and preserve original upstream hash.

Never use a fake SONAME symlink without ABI proof.

---

# 19. Phase M — special handling for libstdc++ on a libc++-oriented host

Inspect `DT_NEEDED` and required symbol versions.

Extract required GLIBCXX versions from Maya binaries and compare them to installed `libstdc++.so.6`.

If the installed Gentoo GCC runtime satisfies Maya, depend on/use it.

This does **not** mean switching Gentoo away from libc++.

If a required GCC runtime cannot be safely provided system-wide, place the correct runtime in `/opt/Autodesk/compat/lib64` using the provenance policy above.

The required outcome is:

```text
ordinary Gentoo applications -> existing libc++ policy
Maya/Autodesk               -> compatible libstdc++ runtime
```

without a global toolchain change.

---

# 20. Phase N — package Maya

Create:

```text
media-gfx/maya
```

using the exact target Maya RPM.

Use current supported Gentoo EAPI/eclasses; EAPI 8 + `rpm.eclass` is valid at plan creation time, but verify against the live tree.

Use a version/slot model suitable for Maya 2027.

Required dependencies must include current packages for:

```text
Autodesk Licensing
Autodesk Identity Manager
ADP Desktop SDK
verified Gentoo runtime dependencies
autodesk-compat-libs if non-empty/needed
```

Preserve Autodesk's intended layout, normally including:

```text
/usr/autodesk/maya2027
/var/opt/Autodesk/Adlm
```

where present in the payload.

Use appropriate prebuilt-binary QA declarations/restrictions according to current Gentoo practice.

Do not strip vendor binaries unless proven safe.

Do not bypass Portage image staging.

---

# 21. Phase O — Maya runtime wrapper

First test Autodesk's native launcher unmodified.

Only add a wrapper if the native launcher cannot establish the correct Gentoo-compatible runtime itself.

If required, install a Portage-owned `/usr/bin/maya` wrapper that sets only verified Maya-specific environment.

Candidate Maya-private paths may include:

```text
/opt/Autodesk/compat/lib64
/usr/autodesk/maya2027/lib/el9
/usr/autodesk/maya2027/plug-ins/xgen/lib
/usr/autodesk/maya2027/lib
```

but include only paths proven necessary on the actual release.

Initially force Maya's Qt to XCB when running under Wayland:

```text
QT_QPA_PLATFORM=xcb
```

Do not set it globally.

Construct `LD_LIBRARY_PATH` safely and only for the Maya process if required.

Do not export Autodesk runtime variables into shell startup files.

---

# 22. Phase P — build QA and merge automation

For each package:

1. generate Manifest;
2. run `pkgcheck`;
3. use `pkgdev` where useful;
4. fix meaningful ebuild/repository issues;
5. tolerate/document expected vendor-prebuilt warnings only when current Gentoo policy allows;
6. commit working package state to overlay git.

Before merge, run Portage dry-runs.

If the dry-run proposes any forbidden platform change, redesign the package automatically.

Merge required infrastructure in dependency order:

```text
account packages if needed
Autodesk Licensing
Autodesk Identity Manager
ADP Desktop SDK
Autodesk compatibility libs if needed
Maya
```

Do not use `--ask`; the goal is autonomous execution.

After each merge, verify representative file ownership with Portage.

If merge fails, diagnose, fix ebuild, regenerate Manifest, retry.

---

# 23. Phase Q — service activation and Maya product registration

Start/enable Autodesk Licensing using the host's native init system.

Run:

```text
/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list
```

If Maya is absent, derive current registration parameters from:

```text
actual Maya RPM scripts
MayaConfig.pit/current equivalent
Autodesk installer metadata
current AUR install logic
```

Never use an old product key copied from Maya 2025/2026 documentation.

Implement idempotent registration, preferably through Maya's `pkg_config()` so:

```bash
emerge --config media-gfx/maya
```

registers only when needed and verifies the result.

The autonomous agent should invoke the registration itself.

No human confirmation is required.

Do not bypass Autodesk licensing.

---

# 24. Phase R — pre-launch automated validation

Before GUI launch, automatically verify:

## R1 ADP

`AdpSDKCore.so` exists and can be resolved by the Maya runtime environment.

## R2 Licensing

Licensing service is alive and Maya registration is listed.

## R3 ELF

Run `lddtree`/equivalent on the primary executable and key components using the exact final launcher environment.

Resolve required `not found` dependencies.

## R4 mayapy

Run:

```bash
/usr/autodesk/maya2027/bin/mayapy -c 'import sys; print(sys.version)'
```

then:

```bash
/usr/autodesk/maya2027/bin/mayapy \
  -c 'import maya.standalone; maya.standalone.initialize(); print("MAYA_STANDALONE_OK")'
```

Adapt path for actual target version.

## R5 batch Maya

Run a noninteractive Maya command sufficient to prove Maya can initialize outside `mayapy`.

Capture logs.

If process exits 255 before licence initialization, investigate ADP Desktop SDK first.

---

# 25. Phase S — Identity Manager and Autodesk sign-in

Launch the final Maya command as the normal desktop user.

Ensure:

```bash
xdg-mime query default x-scheme-handler/adskidmgr
```

points to current Identity Manager.

If authentication is already valid, continue automatically.

If credentials/MFA/EULA are required, invoke H2 and nothing else.

After the human completes the secure interaction, detect successful callback/licensing and continue automatically.

If browser opens but callback fails, autonomously diagnose:

```text
adskidmgr MIME association
desktop file Exec line
Identity Manager ELF dependencies
DBus environment
X11/Wayland backend
browser callback URI
Identity Manager logs
Licensing logs
```

Do not ask the user to troubleshoot.

---

# 26. Phase T — Application Home

Do not apply the Arch `--single-process` workaround pre-emptively.

Test current Gentoo behavior.

If Application Home crashes, hangs, opens blank, or causes a CEF/helper failure:

1. compare current AUR workaround;
2. reproduce the minimum semantic fix;
3. prefer wrapper/argument/text-script adjustment over binary patching;
4. keep it Maya-scoped;
5. document it as removable.

Continue autonomously.

Application Home failure must not be confused with core Maya or licensing failure.

---

# 27. Phase U — automated functional Maya test

Create an automated Maya test script under the work tree.

Use Maya Python/MEL to perform as much validation as possible without asking the user to click anything:

```text
initialize Maya
create a new scene
create primitive geometry
create/assign a basic material
set transforms
add a keyframe
save .ma
save/reopen scene
execute Python
execute MEL
query Maya version
query renderer/graphics information where APIs permit
exit cleanly
```

Run it with Maya/mayapy/batch as appropriate.

Store generated test scenes under:

```text
~/src/native-maya-gentoo/test-output/
```

Do not ask the user to manually perform these checks.

---

# 28. Phase V — GUI and Viewport 2.0 validation

Launch Maya through final desktop/runtime wrapper with:

```text
QT_QPA_PLATFORM=xcb
```

initially when on Wayland.

If the agent has GUI/computer vision access, inspect the Maya window itself.

If the agent does not have GUI observation capability, do not ask the user for a visual confirmation by default. Instead use process state, Maya logs, command/API queries, and automated scripts to establish that the GUI session initializes.

Validate that rendering is not LLVM software rasterization.

Use host:

```bash
glxinfo -B
```

and Maya-visible renderer/device information where possible.

If Viewport fails, diagnose in this order:

```text
XWayland/XCB
Qt platform backend
library search-path shadowing
libGL/libEGL/libglvnd resolution
Mesa/radeonsi
OpenCL ICD interaction
Maya-specific driver bug
```

Do not replace Mesa or install AMDGPU-PRO.

Any workaround must remain Maya-scoped unless an independently broken host graphics configuration is proven; even then, do not redesign the host under this goal.

---

# 29. Phase W — Arnold

If the official Maya installer contains the matching Arnold/MtoA component, package it separately as:

```text
media-gfx/maya-arnold
```

using the exact compatible version supplied by Autodesk.

Install it through Portage.

Test:

```text
MtoA plug-in loads
Arnold renderer initializes
a trivial scene renders on CPU
output image is created
```

Do not require AMD Arnold GPU rendering for success. The AMD GPU is expected to serve Maya's viewport; Arnold CPU is the required renderer validation on this machine unless Autodesk's current release explicitly supports this AMD GPU for Arnold GPU.

Automate the render test.

---

# 30. Phase X — optional Autodesk Maya components

If present in the official installer, autonomously package and attempt installation of:

```text
MayaUSD
Bifrost
LookdevX
Substance
```

Keep them separate Portage packages.

Use the exact compatibility set shipped/recommended for the target Maya release.

A failure in one optional component must not cause the agent to destroy or roll back an otherwise working native Maya installation.

Diagnose and retry reasonable fixes autonomously.

If an optional component remains incompatible after a well-evidenced bounded effort, leave base Maya intact, record the optional failure in the final report, and continue. Do not ask the user whether to proceed without it.

---

# 31. Phase Y — desktop integration

Install a proper Maya desktop entry through the Maya ebuild.

It must launch the final Maya wrapper/command.

Install permitted Autodesk icons.

Update desktop database through normal Gentoo packaging integration.

Ensure Autodesk Identity Manager protocol handler remains correctly registered for the active user.

The final normal user experience should allow:

```bash
maya
```

and launcher-menu startup.

---

# 32. Phase Z — integrity, ownership, reinstallability

Audit representative/static files beneath:

```text
/usr/autodesk
/opt/Autodesk
/usr/share/applications
```

with Portage ownership tools.

Runtime-generated state under `/var/opt/Autodesk` is allowed to be runtime state.

Verify no Autodesk package overwrote an unrelated Gentoo-owned file.

Re-run baseline checks:

```text
profile
compiler configuration
clang
libc++ policy indicators
OpenSSL
Mesa/OpenGL renderer
LLVM
kernel/amdgpu
```

Compare to Phase A.

Re-emerge Maya once:

```bash
emerge -1 media-gfx/maya
```

and ensure no manual copying is required.

Run the relevant reverse-dependency/preserved-libs diagnostics.

Ensure no runtime path points into:

```text
/tmp
/var/tmp/portage
the extraction staging tree
the payload work directory
```

Commit final overlay state.

---

# 33. Autonomous rollback rules

Do not roll back merely because a build/test fails; failures are information and should be repaired.

Automatically revert a scoped change when it demonstrably causes one of:

```text
Portage collision with an unrelated package
host Mesa/OpenGL regression
compiler/stdlib policy change
system OpenSSL regression
unrelated application breakage caused by Autodesk environment leakage
service-account or permission damage
```

Use backups and git commits.

Never restore/delete Autodesk runtime licensing databases blindly. Preserve user/account runtime state unless removal is proven necessary.

If a candidate compatibility strategy violates host-integrity rules, revert it and select the next strategy from the library-resolution hierarchy.

---

# 34. Unrecoverable blocker policy

The agent should exhaust all safe autonomous avenues before declaring a blocker.

Examples of a genuinely unrecoverable blocker:

```text
Autodesk no longer permits this Maya version to authenticate on Linux
a required proprietary Autodesk file is absent from all official payloads
the current Autodesk binary requires a kernel/driver capability unavailable on the host
the only known solution requires a forbidden global host downgrade/replacement
the Autodesk account has no entitlement and authentication proves that fact
```

If such a blocker is proven:

- do not ask an open-ended question;
- do not suggest abandoning native Gentoo unless reporting the blocker;
- preserve the overlay/work/logs;
- produce a concise terminal-state report containing evidence, exact failing component, attempts made, and the minimum external condition required to proceed.

Otherwise, keep working.

---

# 35. Required success criteria

The native Maya installation is complete only when all required criteria below are true:

```text
[ ] Target Maya 2027.x version is known from official payload/documentation.
[ ] Maya is installed through the local Portage overlay.
[ ] Autodesk RPMs were unpacked as source, not installed into an RPM database.
[ ] No container/chroot/VM/FHS environment is used.
[ ] Maya executes as a host Gentoo process.
[ ] Autodesk Licensing Service runs under the host's native init system.
[ ] Maya registration appears in AdskLicensingInstHelper.
[ ] Autodesk Identity Manager launches.
[ ] adskidmgr callback association works.
[ ] Autodesk entitlement/sign-in succeeds.
[ ] ADP Desktop SDK is installed and AdpSDKCore.so is resolvable.
[ ] mayapy initializes maya.standalone.
[ ] Maya batch/core initialization succeeds.
[ ] Maya GUI process starts successfully.
[ ] Automated scene create/save/reopen test succeeds.
[ ] Maya uses the host AMD/Mesa graphics stack rather than software rasterization.
[ ] Maya-specific environment does not leak globally.
[ ] Maya receives compatible libstdc++ without changing the host libc++ policy.
[ ] No global OpenSSL downgrade/replacement occurred.
[ ] No global Qt/Python replacement occurred.
[ ] No Mesa/amdgpu replacement occurred.
[ ] Static Autodesk installation files are Portage-owned where practical.
[ ] Maya can be re-emerged cleanly.
[ ] Arnold CPU test succeeds if the matching Arnold component is supplied by Autodesk.
[ ] Overlay git tree and README document the final installation.
```

Optional MayaUSD/Bifrost/LookdevX/Substance failures should be documented but do not invalidate core Maya success unless they are required by the actual Maya package to start.

---

# 36. Final deliverables produced by the implementing agent

At completion, leave:

```text
/var/db/repos/local-autodesk/
    working local overlay under git

~/src/native-maya-gentoo/
    STATE.md
    DECISIONS.md
    logs/
    test-output/
    payload hash/inventory records
    backups/
```

The overlay README must include:

```text
tested Maya version/build
Gentoo host characteristics relevant to compatibility
required official Autodesk installer filename/hash
one-command payload import procedure
package list
installation/reinstallation procedure
service behavior
registration behavior
XWayland/XCB behavior
private compatibility libraries and provenance
known workarounds
optional component status
upgrade procedure
uninstall procedure
```

Do not include proprietary Autodesk binaries in git.

---

# 37. Final response behavior

On successful completion, the agent should report only useful results:

```text
installed Maya version
command to launch it
Portage package names installed
licensing/authentication status
graphics/viewport result
Arnold result
optional component status
overlay path
any remaining non-blocking workaround
```

Do not ask the user what they want to do next.

If a HUMAN INTERVENTION GATE is active, send only the exact intervention instruction required by that gate plus the fact that execution will resume automatically afterwards.

The agent must not turn this autonomous goal into a conversation.

---

# 38. Diagnostic priority reference

When Maya fails, use this order:

```text
1. identify exact failing process/component and exit code
2. capture stderr/logs
3. check current Autodesk-known issue
4. inspect actual upstream payload/scripts
5. compare current AUR native implementation
6. inspect ELF interpreter/DT_NEEDED/RPATH/RUNPATH
7. check Maya/Autodesk bundled library
8. check exact Gentoo ABI/provider
9. use Autodesk-private compatibility library if required
10. use Maya-scoped environment adjustment
11. patch a launcher/script
12. binary patch only as last resort
```

Special case:

```text
Maya/maya.bin/batch exits 255 before licensing
    -> verify ADP Desktop SDK and AdpSDKCore.so first
```

Licence error:

```text
    -> Licensing Service
    -> product registration
    -> Identity Manager
    -> entitlement
```

Graphics error:

```text
    -> XWayland/XCB
    -> Qt backend
    -> libGL/libEGL/libglvnd search order
    -> Mesa/radeonsi visibility
    -> OpenCL interaction
    -> Maya/driver issue
```

Never solve a missing library by creating an unverified same-name symlink.

---

# 39. Core design summary

The desired final system is:

```text
Gentoo host
│
├── existing kernel + amdgpu
├── existing Mesa/radeonsi + libglvnd
├── existing compiler/libc++ policy unchanged
│
├── Portage local-autodesk overlay
│   ├── Autodesk Licensing
│   ├── Autodesk Identity Manager
│   ├── ADP Desktop SDK
│   ├── narrowly scoped Autodesk compatibility libs
│   ├── Maya 2027.x
│   └── optional Maya components
│
├── /opt/Autodesk/...
├── /usr/autodesk/maya2027/...
└── /usr/bin/maya
        │
        └── normal native host process
```

The user should ultimately type:

```bash
maya
```

and receive a working, licensed, native Maya installation without any container or VM.

That is the definition of completion.
