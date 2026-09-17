# AUTONOMOUS REPOSITORY PRODUCTIZATION PLAN
## Turn the native Maya-on-Gentoo work into a reusable Gentoo overlay/repository

## 0. Mission

Transform the existing `maya-gentoo` Git repository from a documentation/handoff repository into the **authoritative, self-contained community Gentoo repository for installing native Autodesk Maya on Gentoo**.

The finished repository should be usable in the same practical spirit as an AUR package:

1. a Gentoo user discovers/clones/adds the repository;
2. the user downloads the official proprietary Autodesk Maya Linux installer from Autodesk;
3. one repository-provided importer/preparation step converts that single official archive into the distfiles expected by Portage;
4. Portage installs Autodesk Licensing, Identity Manager, ADP Desktop SDK, Maya, compatibility packages, and supported optional Maya components;
5. the user authenticates with Autodesk when Autodesk requires it;
6. `maya` launches natively on Gentoo;
7. the repository itself contains the ebuilds, patches, init/service integration, importer, tests, documentation, compatibility decisions, and maintenance/update workflow needed to reproduce and maintain the installation.

The repository MUST NOT redistribute Autodesk proprietary payloads, credentials, tokens, cookies, licence databases, entitlement information, or other private account data.

This task is **not** to reinstall Maya from scratch unless needed for repository validation. A working native installation already exists. The task is to productize the successful work into a reusable public-quality repository and then prove that the repository—not an external development overlay—is sufficient to reproduce/re-emerge the working installation.

---

# 1. Current repository state that must guide the work

The current Git repository is documentation-heavy and is **not yet an installable Gentoo overlay**.

At the time this plan was created, the repository root contains essentially:

```text
.gitignore
LICENSE
README.md
MAYA_GENTOO_HANDOFF.md
NATIVE_MAYA_GENTOO_AUTONOMOUS_PLAN.md
docs/
├── ARTIFACTS_AND_EVIDENCE.md
└── PORTAGE_GUIDE.md
```

The current documentation records that the actual successful implementation exists outside the repository at locations such as:

```text
/home/p2949/src/native-maya-gentoo/overlay-worktree/
/var/db/repos/local-autodesk/
/home/p2949/src/native-maya-gentoo/scripts/import-autodesk-payload.sh
/home/p2949/src/native-maya-gentoo/STATE.md
/home/p2949/src/native-maya-gentoo/DECISIONS.md
/home/p2949/src/native-maya-gentoo/logs/
/home/p2949/src/native-maya-gentoo/test-output/
```

The documentation says the native Maya installation is already validated and includes working packages corresponding to:

```text
media-gfx/maya-2027.2
app-autodesk/adsk-licensing-16.0.3.14414
app-autodesk/adsk-identity-manager-1.18.1.2
app-autodesk/adp-desktop-sdk-6.3.34
media-gfx/maya-usd-0.37.0
media-gfx/bifrost-3.1.0.8
media-gfx/lookdevx-2.2.0
media-gfx/substance-maya-3.0.6
```

The current documentation also records successful compatibility work including:

```text
native OpenRC Autodesk Licensing service
XCB/XWayland scoped Maya launcher
ADP Desktop SDK integration
Identity Manager authentication
Gentoo certificate-path compatibility
Maya/libmd startup collision handling
private compatibility libraries
MayaUSD/Bifrost/LookdevX/Substance packaging
mayapy and Maya batch validation
Viewport 2.0 validation
clean Portage re-emerge
```

Treat the actual development overlay/work tree and live installed packages as the primary implementation evidence.

Do not rewrite working ebuilds from memory if the successful source exists locally.

---

# 2. Controlling outcome

At completion, the repository root itself should be a valid Gentoo ebuild repository/overlay.

A representative final structure should resemble:

```text
maya-gentoo/
├── README.md
├── LICENSE
├── .gitignore
├── metadata/
│   └── layout.conf
├── profiles/
│   ├── repo_name
│   └── categories
├── licenses/
│   └── <Autodesk licence token if required>
├── acct-group/
│   └── ...
├── acct-user/
│   └── ...
├── app-autodesk/
│   ├── metadata.xml
│   ├── adsk-licensing/
│   │   ├── metadata.xml
│   │   ├── Manifest
│   │   ├── adsk-licensing-<version>.ebuild
│   │   └── files/
│   ├── adsk-identity-manager/
│   ├── adp-desktop-sdk/
│   └── autodesk-compat-libs/
├── media-gfx/
│   ├── maya/
│   ├── maya-usd/
│   ├── bifrost/
│   ├── lookdevx/
│   └── substance-maya/
├── tools/
│   ├── import-autodesk-payload.sh
│   ├── preflight.sh
│   ├── verify-install.sh
│   ├── qa.sh
│   └── <other small justified helpers>
├── releases/
│   └── 2027.2/
│       ├── release metadata
│       └── hashes/component map
├── docs/
│   ├── INSTALL.md
│   ├── TROUBLESHOOTING.md
│   ├── COMPATIBILITY.md
│   ├── ARCHITECTURE.md
│   ├── MAINTAINER.md
│   ├── TESTING.md
│   └── development/
│       ├── 2027.2-validation.md
│       ├── decisions.md
│       └── original-autonomous-plan.md
├── CONTRIBUTING.md
└── SECURITY.md
```

This is a target model, not a command to create empty directories mechanically. Only keep files/directories that carry real value.

The repository root should be directly consumable by Portage; do **not** hide the real overlay inside a nested `overlay/` directory unless a compelling technical reason is proven.

---

# 3. Primary user experience

Design the repository around this end-user flow.

## Preferred repository registration

Where supported:

```bash
doas eselect repository add maya-gentoo git <actual-origin-url>
doas emaint sync -r maya-gentoo
```

or the current Gentoo-equivalent commands discovered from the live tools/documentation.

The README must use the repository's actual configured public origin URL, discovered from Git, rather than an invented placeholder in the committed final documentation.

Provide a manual `repos.conf`/git clone fallback for users who do not use `eselect-repository`.

## Autodesk payload

The user downloads **one official outer Maya Linux archive** from Autodesk.

For the tested release this is currently documented as:

```text
Autodesk_Maya_2027_2_Update_Linux_64bit.tgz
Maya 2027.2 build 1839
SHA-256 399250a3a2c306a403053da077221f7592170ca0d6196b8cbf2bfd17e25f94fe
```

The repository-provided importer handles internal component extraction and placement into Portage `DISTDIR`.

The user should not need to manually extract ten RPMs/ZIPs or discover component filenames.

Target experience:

```bash
/var/db/repos/maya-gentoo/tools/import-autodesk-payload.sh \
    ~/Downloads/Autodesk_Maya_2027_2_Update_Linux_64bit.tgz
```

The script must derive `DISTDIR` through Portage rather than assume `/var/cache/distfiles`.

## Portage configuration

Document and, where safely useful, automate only the narrowly required:

```text
licence acceptance
keyword acceptance if the user's profile requires it
repository enablement
```

Do not require global `ACCEPT_LICENSE="*"` or global `ACCEPT_KEYWORDS`.

Use package-scoped examples.

## Installation

The normal installation should be expressible with ordinary Portage commands, e.g.:

```bash
doas emerge --ask media-gfx/maya
```

or a small documented set of package atoms if the package graph cannot cleanly express required dependencies.

Required runtime dependencies should be represented in ebuild dependencies so users do **not** need to memorize a manual merge order.

Optional components should remain separate packages unless a clean optional meta-package/USE-flag design demonstrably improves usability without creating dependency cycles.

## Authentication

When Autodesk requires sign-in/MFA/EULA/consent, the account holder performs only that secure action.

Everything else should be handled by package/scripts/normal system tooling.

## Launch

```bash
maya
```

---

# 4. Autonomous execution mode

This is an implementation plan, not a discussion prompt.

The implementing LLM MUST:

1. read this entire file before modifying the repository;
2. inspect the current Git repository, Git history, configured remotes, current external development overlay, live overlay, installed packages, importer, state/decision files, and relevant logs;
3. use the already successful implementation as source material;
4. make routine technical decisions autonomously;
5. edit, move, copy, sanitize, refactor, test, commit, diagnose, repair, and retry without asking the user for permission;
6. keep the current working Maya installation usable throughout;
7. prove that the finished repository is standalone by re-emerging packages from the repository rather than the old external development overlay;
8. avoid asking open-ended questions;
9. never ask “should I continue?” or “which option do you prefer?”;
10. pause only at an explicit HUMAN INTERVENTION GATE below.

If multiple valid implementations exist, choose in this order:

1. repository usability for ordinary Gentoo users;
2. host safety;
3. Portage correctness;
4. reproducibility;
5. least invasive behavior;
6. maintainability;
7. documentation clarity;
8. simplicity.

---

# 5. Human intervention gates — the only allowed pauses

## H1 — privileged authentication

Test:

```bash
doas -n true
```

If it succeeds, continue.

If the terminal itself requires administrator password entry, request only:

> HUMAN ACTION REQUIRED — privilege authentication: enter your administrator password directly in the active terminal prompt. Do not send the password in chat. Execution will continue automatically.

Never request the password in text.

Do not weaken `doas`/sudo policy to avoid this gate.

## H2 — Autodesk secure account action

If end-to-end validation requires renewed Autodesk login, MFA, account selection, EULA acceptance, or account-holder consent, open the correct Autodesk flow and request only:

> HUMAN ACTION REQUIRED — Autodesk account: complete the requested sign-in/MFA/consent in the secure Autodesk window. Do not send credentials or tokens in chat. Execution will continue automatically when authentication completes.

Do not require the user to reply “continue”.

## H3 — official Autodesk payload unavailable

Before using this gate, search:

```text
~/Downloads
existing project/work directories
Portage DISTDIR
the original native-maya work tree
the live development artifacts
```

If the known official payload is unavailable and cannot be obtained with the existing authenticated Autodesk browser flow, request only:

> HUMAN ACTION REQUIRED — Autodesk payload: download the official Linux installer archive for the tested Maya release from Autodesk and place it unchanged in `~/Downloads/`. Execution will continue automatically when the file appears.

Do not ask the user to extract RPMs manually.

## H4 — actual secret found in Git history

If a real reusable credential, OAuth token, cookie, private key, password, or other live secret is found in repository history:

1. stop publishing/pushing work;
2. identify the exact secret class without printing its value;
3. request only the necessary rotation/revocation action;
4. sanitize/rewrite repository history autonomously afterwards if necessary.

Machine usernames, harmless absolute paths, generic product identifiers, hardware descriptions, and test logs are **not** automatically secrets.

Do not rewrite history merely for cosmetic path cleanup.

---

# 6. Phase 1 — audit the repository and all external source-of-truth artifacts

Create/update an execution work area and `STATE.md`.

Record:

```bash
pwd
git status --short --branch
git remote -v
git log --oneline --decorate --all -n 100
git ls-files
```

Determine the actual repository root.

Read every current documentation file completely.

Inspect the current working implementation referenced by the docs:

```text
/home/p2949/src/native-maya-gentoo/
```

Specifically inspect:

```text
overlay-worktree/
scripts/import-autodesk-payload.sh
STATE.md
DECISIONS.md
logs/
test-output/
payload records
```

Inspect the live overlay:

```text
/var/db/repos/local-autodesk/
```

Compare:

```text
development overlay
live overlay
installed package CONTENTS
current documentation
current Git repository
```

Do not assume they are identical.

Produce an internal audit table containing:

```text
artifact
authoritative source
current repo contains it? yes/no
needs sanitization? yes/no
action
```

Examples:

```text
maya ebuild
OpenRC init script
Identity Manager ebuild
ADP SDK ebuild
compat package ebuilds
Maya launcher
libmd compatibility file
certificate compatibility handling
import script
release hashes
metadata.xml
Manifests
tests
README material
troubleshooting evidence
```

---

# 7. Phase 2 — inspect the Git history for privacy/proprietary mistakes

Search current tree and history for:

```text
/home/p2949
OAuth
token
cookie
Authorization:
Bearer
password
client_secret
private key markers
entitlement databases
Autodesk downloaded binary files
RPMs
TGZ/ZIP payloads
licence database files
```

Use both filename and content/history searches.

Examples:

```bash
git log --all --stat
git log -p --all
git grep
git rev-list --objects --all
```

Use a secret scanner if already available or easy to install, but do not require one if careful Git inspection is sufficient.

Classify findings:

```text
public technical evidence
machine-specific but harmless
private/sensitive
proprietary redistributable? no
actual secret
```

Current documentation should be sanitized for portability even when historical content is harmless.

Only invoke H4 for genuine secrets.

---

# 8. Phase 3 — make the repository root a valid Gentoo repository

The final Git root should itself satisfy normal Gentoo overlay structure.

Create/validate:

```text
metadata/layout.conf
profiles/repo_name
profiles/categories
```

Use a stable repository name such as:

```text
maya-gentoo
```

unless the repository already has an established valid name that should be preserved.

Set the Gentoo repository as master according to current overlay practice.

Do not use deprecated `PORTDIR_OVERLAY`.

Declare custom category `app-autodesk` correctly in `profiles/categories`.

Add required category `metadata.xml` when current Gentoo repository rules require it.

Every package directory must contain current valid `metadata.xml`.

Use the current Gentoo Development Guide and live Gentoo tree as authority for repository metadata.

Run XML validation where appropriate.

Do not commit Portage caches.

---

# 9. Phase 4 — migrate the actual successful overlay into the repository

Copy/reconcile the successful source from the development overlay into the repository.

Do not blindly overwrite newer repository work.

For each package:

1. compare development overlay and live overlay;
2. determine which version produced the successful installed state;
3. inspect recent Git commits in the development overlay;
4. copy the latest correct ebuild/files/metadata into the repository;
5. preserve meaningful commit history in the new repository through clean commits, not by copying `.git`;
6. ensure no absolute development-machine paths exist in ebuilds or scripts unless they are runtime paths required by Autodesk itself.

Expected package families include:

```text
acct-group/* if required
acct-user/* if required

app-autodesk/adsk-licensing
app-autodesk/adsk-identity-manager
app-autodesk/adp-desktop-sdk
app-autodesk/autodesk-compat-libs or its actual split packages

media-gfx/maya
media-gfx/maya-usd
media-gfx/bifrost
media-gfx/lookdevx
media-gfx/substance-maya
```

If compatibility libraries are currently split into several packages rather than `autodesk-compat-libs`, preserve the split if it is technically sound.

Do not invent Arnold if the tested Autodesk payload did not include a compatible MtoA/Arnold package.

Instead document Arnold status accurately.

---

# 10. Phase 5 — validate package metadata and Gentoo policy

For each package:

- ensure package name/version is appropriate;
- ensure EAPI is current/supported;
- validate inherited eclasses;
- validate `DEPEND`, `RDEPEND`, `BDEPEND`, `PDEPEND`, `IDEPEND` semantics;
- ensure binary/prebuilt QA overrides are justified and minimal;
- ensure `RESTRICT` matches Autodesk distribution constraints;
- ensure `LICENSE` accurately represents Autodesk/private components;
- ensure `SLOT`/subslot strategy is coherent;
- ensure `KEYWORDS` accurately reflect actually tested architectures;
- ensure `metadata.xml` describes maintainership/upstream/use flags;
- ensure files under `files/` are non-proprietary and redistributable;
- ensure Manifests correspond to the exact tested distfiles.

Do not claim stable Gentoo keywording merely because the package worked on one machine.

If only amd64 has been tested, represent that honestly.

Use local USE flags only when they represent meaningful optional behavior.

Do not add USE flags merely to make the package look configurable.

---

# 11. Phase 6 — create a release metadata model

The repository should not scatter tested release data through scripts and docs.

Create a simple machine-readable release definition for each supported/tested Maya release.

For example:

```text
releases/2027.2/release.json
```

or another simple format justified by the scripts already present.

It should contain non-secret metadata such as:

```text
Maya release
Maya build
outer Autodesk archive expected filename/pattern
outer archive SHA-256
component logical names
component upstream filenames
component versions
component SHA-256 hashes where known
corresponding Gentoo package atoms
registration metadata source/location, not account credentials
known optional components present/absent
tested date
```

Do not store:

```text
credentials
OAuth callback URLs containing tokens
cookies
entitlement databases
user IDs
machine IDs
```

Prefer the importer, verification tools, and documentation to read from the release metadata rather than duplicate constants.

If retrofitting release metadata would make working ebuilds unnecessarily fragile, keep ebuild constants where Portage requires them and make the release file a verified single reference rather than a runtime dependency.

---

# 12. Phase 7 — productize the payload importer

Take the known working:

```text
/home/p2949/src/native-maya-gentoo/scripts/import-autodesk-payload.sh
```

and make it repository-quality.

Move/copy it into:

```text
tools/import-autodesk-payload.sh
```

Requirements:

1. no `/home/p2949` or other fixed username/path;
2. determine repository root relative to the script;
3. obtain `DISTDIR` using `portageq envvar DISTDIR`;
4. accept the outer official Autodesk archive as its primary positional argument;
5. identify supported release automatically from archive metadata/hash;
6. verify outer archive hash for known tested releases;
7. extract to `mktemp`/temporary work area;
8. discover expected components from the actual payload;
9. verify component hashes where release metadata provides them;
10. copy/install required component distfiles into `DISTDIR`;
11. preserve upstream filenames expected by ebuilds;
12. never execute RPM install scripts;
13. never call `rpm -i`/`rpm -U`;
14. never modify `/usr/autodesk`, `/opt/Autodesk`, or `/var/opt/Autodesk`;
15. never write proprietary payloads into the Git tree;
16. refuse unknown outer archives by default with a useful message;
17. support an explicit maintainer inspection mode for future unknown releases without pretending they are supported;
18. clean temporary extraction automatically;
19. print a concise summary of imported components;
20. return nonzero on incomplete/mismatched payload.

If `DISTDIR` is not writable, use privilege escalation only for the final file installation step and preserve ownership/mode appropriate for Portage.

Do not require the user to know internal Autodesk component paths.

---

# 13. Phase 8 — add repository preflight and verification tooling

Create small tools only where they meaningfully reduce user mistakes.

## `tools/preflight.sh`

Should inspect, without making destructive changes:

```text
Gentoo detected
amd64 architecture
Portage available
repository recognized
target release distfiles present
required licence acceptance state
required keyword state
init system
X11/XWayland availability
basic host OpenGL/Mesa visibility
```

Do not turn the script into a second package manager.

It should report exact Portage-native remediation.

## `tools/verify-install.sh`

Should verify after installation:

```text
installed package versions
Licensing service executable/service state
AdskLicensingInstHelper availability
ADP AdpSDKCore.so
Identity Manager installation
adskidmgr MIME association
mayapy standalone initialization
Maya batch initialization
Maya executable
Viewport/GL evidence where programmatically obtainable
```

Do not print account tokens or dump full private licence databases.

## `tools/qa.sh`

For maintainers:

```text
bash -n
shellcheck when available
metadata XML validation
pkgcheck scan
Manifest checks
grep for banned machine-specific paths
grep for proprietary payload extensions
grep for obvious secret patterns
```

Fail loudly when the repository would accidentally ship an Autodesk payload.

---

# 14. Phase 9 — clean up portability defects in the successful implementation

Audit the imported ebuilds/scripts for assumptions specific to the original workstation.

Pay special attention to:

```text
/home/p2949 paths
DISPLAY=:0
hard-coded username
hard-coded home directory
hard-coded Portage DISTDIR
hard-coded development overlay path
hard-coded log dates
RX 9070 XT-specific logic
Mesa version-specific logic
Wayland compositor-specific logic
libc++ host-specific assumptions
```

Convert machine-specific behavior to runtime discovery.

The successful test machine may remain documented as a tested environment, but must not define the install interface.

## Display handling

Never force:

```text
DISPLAY=:0
```

in the permanent launcher.

Use the user's existing `DISPLAY`.

If running under Wayland and Maya requires XCB/XWayland, apply only scoped:

```text
QT_QPA_PLATFORM=xcb
GDK_BACKEND=x11
```

and clear only the variables proven to conflict.

Keep that behavior in Maya's wrapper, not globally.

## Certificate handling

Review the current certificate-path workaround.

Prefer a Maya/Autodesk-scoped environment or package-owned compatibility path to arbitrary unmanaged system-wide files.

If compatibility symlinks outside `/opt/Autodesk` are genuinely required by Autodesk binaries, make them explicitly Portage-owned, collision-safe, documented, and based on Gentoo's actual CA bundle.

Do not hard-code a user's certificate path.

## `libmd` workaround

The current handoff says a Maya-private empty:

```text
/usr/autodesk/maya2027/lib/libmd.so
```

prevents Maya from resolving Gentoo's incompatible `libmd`.

Before publishing this unconditionally:

1. inspect the actual working file/ebuild implementation;
2. document exactly why it is required;
3. confirm it does not mask a legitimate Maya dependency;
4. keep it strictly inside Maya's private library namespace;
5. add regression validation showing Maya starts with it;
6. avoid touching Gentoo's system `libmd`.

If it is host-specific rather than universally required, implement the narrowest safe conditional behavior.

---

# 15. Phase 10 — make init-system support reusable

The current tested installation uses OpenRC.

Preserve the working OpenRC service.

Inspect the Autodesk RPM for its upstream systemd unit.

For a public Gentoo overlay, support both Gentoo init families where technically straightforward:

```text
OpenRC
systemd
```

Install the appropriate service files using normal Gentoo helpers.

Do not auto-enable/start services in surprising ways beyond normal package expectations.

Documentation should show:

OpenRC:

```bash
doas rc-update add adsklicensing default
doas rc-service adsklicensing start
```

systemd:

```bash
doas systemctl enable --now adsklicensing.service
```

using the **actual installed unit name**.

If systemd cannot be validated on the current machine, label it **packaged but untested** rather than claiming tested support.

Do not create a fake systemd success claim.

---

# 16. Phase 11 — make licensing setup reproducible but account-safe

The repository must automate software registration mechanics without embedding user account state.

Review the existing `pkg_config()`/registration implementation.

Target:

```bash
doas emerge --config media-gfx/maya
```

or another documented idempotent Portage-native mechanism.

It should:

1. check whether Maya is already registered;
2. derive/use release-specific product registration values from tested package metadata;
3. register only if absent;
4. verify registration afterwards;
5. never log tokens/credentials;
6. never bypass Autodesk entitlement checks.

Generic Autodesk product identifiers that are part of the official software packaging may be committed when technically necessary and not secret, but do not present them as user licence keys.

Authentication remains Autodesk-managed.

---

# 17. Phase 12 — rethink optional components from the user's perspective

Keep base Maya install reliable.

Audit:

```text
maya-usd
bifrost
lookdevx
substance-maya
Arnold/MtoA status
```

Decide whether the best public interface is:

A. separate explicit packages only, or
B. separate packages plus a small meta package, or
C. optional dependency USE flags on a dedicated meta package.

Do **not** create circular dependencies.

Do **not** merge optional components into the base Maya ebuild merely for convenience.

Recommended baseline:

```text
media-gfx/maya
    -> required Maya runtime only

optional:
media-gfx/maya-usd
media-gfx/bifrost
media-gfx/lookdevx
media-gfx/substance-maya
```

If a meta package is useful, it should depend on these packages rather than duplicate installation logic.

Clearly document that the tested 2027.2 payload did not contain a matching Arnold/MtoA package if that remains true.

---

# 18. Phase 13 — rewrite README as the real front door

The README should no longer say merely “this repository documents…”

It should say that this repository **is a Gentoo overlay for native Autodesk Maya**.

Keep README concise and task-oriented.

Recommended structure:

```text
# Maya Gentoo

short statement
unsupported/community disclaimer
what "native" means

## Supported/tested versions

## Requirements

## Quick start
1. add repository
2. download official Autodesk archive
3. import payload
4. configure licence/keywords if needed
5. emerge Maya
6. start licensing service
7. register/sign in if needed
8. launch maya

## Optional components

## Known limitations
Arnold status
Wayland/XWayland
Autodesk support status

## Documentation links

## Legal
Autodesk payload not redistributed
repository code licence
```

README commands must be copy/paste-safe and host-independent.

No `/home/p2949`.

No `DISPLAY=:0`.

No dated test log paths.

No commands that point to the original external development overlay.

---

# 19. Phase 14 — replace `docs/PORTAGE_GUIDE.md` with a public installation guide

Rewrite the guide around a **fresh user who only has this Git repository and the official Autodesk outer archive**.

It must explain:

```text
prerequisites
adding the repository
manual clone/repo.conf fallback
obtaining Autodesk archive
hash verification
running importer
Portage licence acceptance
keywording if needed
emerging Maya
service setup for OpenRC/systemd
Maya registration
Autodesk login
launch
verification
optional components
uninstall/update
```

Use placeholders such as:

```text
${HOME}
<user>
<repo-path>
```

only where commands cannot discover paths automatically.

Prefer shell commands that discover paths.

Do not document the development machine as if it were required.

---

# 20. Phase 15 — preserve the successful engineering history in the right place

The existing:

```text
MAYA_GENTOO_HANDOFF.md
NATIVE_MAYA_GENTOO_AUTONOMOUS_PLAN.md
docs/ARTIFACTS_AND_EVIDENCE.md
```

contain valuable implementation knowledge but are not ideal front-door documents.

Refactor them.

Recommended:

```text
docs/development/original-autonomous-plan.md
docs/development/2027.2-validation.md
docs/development/decisions.md
```

Migrate the useful parts of:

```text
STATE.md
DECISIONS.md
MAYA_GENTOO_HANDOFF.md
ARTIFACTS_AND_EVIDENCE.md
```

into these repository-contained documents.

Do not copy raw private logs wholesale.

Instead preserve concise evidence:

```text
failure signature
diagnosis
fix
validation command
result
affected package/commit
```

Replace:

```text
/home/p2949/...
```

with repository-relative or generic paths unless a historical path itself is relevant evidence.

Hardware-specific validation should be clearly marked:

```text
Tested environment, not a requirement
```

For example:

```text
AMD Radeon RX 9070 XT
Mesa ...
OpenRC
Wayland compositor + XWayland
```

Do not imply all users must match it.

`docs/ARTIFACTS_AND_EVIDENCE.md` must no longer point primarily to files that do not exist in the repository.

---

# 21. Phase 16 — create `docs/COMPATIBILITY.md`

Document a matrix such as:

```text
Maya version
status
outer archive hash
Gentoo init tested
desktop/session tested
GPU/driver tested
optional components
known workarounds
```

Use precise labels:

```text
tested
packaged but untested
unsupported
not available in tested payload
```

Do not claim generic compatibility from one machine.

Include host/toolchain notes only as evidence.

---

# 22. Phase 17 — create `docs/TROUBLESHOOTING.md`

Convert solved problems into reusable symptom-driven diagnostics.

Sections should include at least:

```text
Maya exits 255 before licence UI
    -> ADP / AdpSDKCore.so

Qt tries Wayland / GUI aborts
    -> XCB/XWayland wrapper

TinputDeviceManager::createDeviceList crash
    -> Maya-private libmd collision handling

Identity Manager curl 77 / status 3030
    -> certificate paths / CA bundle

Autodesk login opens but callback fails
    -> adskidmgr MIME association and Identity Manager

Licensing service won't start
    -> service logs / ELF / permissions

Maya starts with software rendering
    -> libGL/libglvnd/Mesa search path

libtiff version warning
    -> documented non-fatal status if still true

Rusticl/OpenCL warning
    -> distinguish from VP2 OpenGL
```

Use generic commands to find current logs rather than a hard-coded date.

Never tell users to replace Mesa, install AMDGPU-PRO, globally set `LD_LIBRARY_PATH`, or install RPMs directly.

---

# 23. Phase 18 — create `docs/ARCHITECTURE.md`

Explain why the repository is structured as separate packages:

```text
Autodesk Licensing
Identity Manager
ADP Desktop SDK
compatibility runtimes
Maya
optional components
```

Explain:

```text
RPMs are upstream source archives, not installed packages
Portage owns files
private compatibility libs protect the host
Maya wrapper scopes X11/library/certificate behavior
no container/VM
```

This is where deeper design rationale belongs, not in the Quick Start.

---

# 24. Phase 19 — create `docs/MAINTAINER.md`

Make future Maya updates reproducible.

Document an update workflow:

```text
1. obtain new official outer installer
2. run importer in maintainer-inspect mode
3. record archive/component hashes
4. inspect RPM metadata/scripts
5. compare versions/file layouts
6. update release metadata
7. bump ebuilds
8. regenerate Manifests
9. pkgcheck/QA
10. Portage pretend
11. merge
12. registration validation
13. mayapy
14. batch
15. GUI/Viewport
16. optional components
17. clean re-emerge
18. update compatibility matrix
19. commit/tag
```

Document how to add a new release without redistributing Autodesk binaries.

Include a section specifically for Autodesk payloads changing in-place: do not silently update Manifest hashes; investigate and record why.

---

# 25. Phase 20 — add contributor/security guidance

Create `CONTRIBUTING.md` covering:

```text
do not submit Autodesk binaries
do not submit account/licensing state
run tools/qa.sh
run pkgcheck
how to provide logs safely
how to add/update a Maya version
commit style
```

Create `SECURITY.md` explaining how to report:

```text
credential exposure
unsafe installer behavior
path/privilege vulnerabilities in scripts
supply-chain/hash issues
```

Do not encourage users to paste complete Identity Manager/licensing logs publicly without reviewing them for account data.

---

# 26. Phase 21 — legal/licence clarity

Keep the repository's existing free-software licence if appropriate.

Make clear:

```text
repository-authored ebuilds/scripts/docs -> repository licence
Autodesk Maya and Autodesk payloads -> Autodesk proprietary terms
Autodesk payloads are not included
the repository is not affiliated with or supported by Autodesk
```

Do not imply GPL licensing of Autodesk binaries merely because the repository itself is GPL.

Validate that any local `licenses/<token>` content and ebuild `LICENSE` values are appropriate for Gentoo/Autodesk packaging.

Do not invent legal claims.

---

# 27. Phase 22 — eliminate all machine-specific install documentation

Run automated scans across tracked text files for:

```text
/home/p2949
/home/<actual-user>
Desktop/maya
src/native-maya-gentoo/overlay-worktree
/var/db/repos/local-autodesk
DISPLAY=:0
MayaCLM-<specific-date>
RX 9070 XT
Mesa 26.2.0-devel
```

Not every match must disappear.

Rules:

- install/user-facing docs: no original-machine absolute paths;
- historical validation docs: hardware/version references allowed if clearly marked as evidence;
- source/ebuild/scripts: no user-specific absolute paths;
- live repository examples: repository name should be `maya-gentoo`, not `local-autodesk`.

Keep Autodesk's own required absolute paths such as:

```text
/usr/autodesk/maya2027
/opt/Autodesk
/var/opt/Autodesk
```

---

# 28. Phase 23 — repository-level QA

Build `tools/qa.sh` and run equivalent checks manually during development.

At minimum:

```text
git status cleanliness
bash -n scripts
shellcheck where available
xmllint for metadata.xml
pkgcheck scan
Manifest verification
no proprietary extensions tracked
no machine-specific source paths
no obvious secrets
no broken documentation links
```

Check Git for tracked proprietary files:

```bash
git ls-files '*.rpm' '*.tgz' '*.zip' '*.tar.gz'
```

This should be empty except if a tiny redistributable test fixture exists and has been explicitly justified; Autodesk payloads must never appear.

Check file sizes for accidental binary blobs.

---

# 29. Phase 24 — optional CI

Inspect the configured Git remote.

If it is hosted on GitHub and a reliable low-maintenance CI can be implemented without Autodesk proprietary sources, add it.

CI should focus on source/repository QA:

```text
shell syntax/shellcheck
XML validation
pkgcheck repository scan
proprietary-payload guard
machine-path/secret guard
```

Do not make CI download Maya.

Do not make CI pretend it has validated runtime Maya.

If running `pkgcheck` in CI would require a fragile/huge infrastructure setup, prefer a strong local `tools/qa.sh` over an unreliable CI badge.

Never let optional CI block completion of the repository productization.

---

# 30. Phase 25 — test the importer from a consumer perspective

Use the known official 2027.2 outer archive.

Test the repository copy of the importer, not the old external script.

Use a temporary DISTDIR when possible first:

```text
temporary clean directory
```

Confirm that from only:

```text
repository
official outer Maya archive
```

the importer reproduces the exact expected component distfiles/hashes.

Then populate the real Portage DISTDIR as required.

The importer must not depend on:

```text
/home/p2949/src/native-maya-gentoo
old overlay-worktree
old payload maps outside repo
live overlay files
```

---

# 31. Phase 26 — standalone repository install test

This is the key proof.

The agent must prove that the current repository can replace the old `local-autodesk`/development overlay.

Do this safely.

## Preparation

Back up:

```text
/etc/portage/repos.conf/local-autodesk.conf
any Maya-specific package.use
any Maya-specific package.accept_keywords
any Maya-specific package.license
```

Record installed Autodesk package versions and repository origins.

## Add the new repository as a separate Portage repository

Use the current Git working tree or a fresh clone of it under a new repository name, preferably:

```text
maya-gentoo
```

Ensure Portage resolves packages from `::maya-gentoo`, not `::local-autodesk`.

Temporarily disable the old overlay or lower/remove it from resolution **only after** the new repository is recognized and equivalent packages are available.

Do not delete the old overlay yet.

## Pretend

Run:

```bash
emerge --pretend --verbose media-gfx/maya
```

and optional packages.

Reject unexpected host-wide dependency changes.

## Re-emerge from new repository

Re-emerge the installed Maya stack from `::maya-gentoo`.

Verify with Portage package metadata that the installed packages now originate from the new repository.

No installed static file should require the old development overlay.

If a package fails:

```text
diagnose
fix repo source
Manifest
QA
retry
```

Do not fall back silently to the old overlay.

---

# 32. Phase 27 — runtime validation after migration to the repository

After packages are installed from the repository, rerun the successful core validations.

Required:

```text
Autodesk Licensing service healthy
AdskLicensingInstHelper works
ADP AdpSDKCore.so present
Identity Manager installed
adskidmgr handler valid
mayapy standalone initialization
Maya batch initialization
Maya GUI launch
Viewport 2.0 initialization
automated scene save/reopen
clean re-emerge of media-gfx/maya
```

Use existing authenticated account state; do not force logout/relogin merely to test the repository.

If authentication has expired and a login is truly required, use H2.

For optional installed components:

```text
MayaUSD loads
Bifrost loads
LookdevX loads
Substance loads
```

to the extent they are reasonably script-testable.

Do not require Arnold when the official tested payload does not provide it.

---

# 33. Phase 28 — remove dependence on the old development overlay

Only after the standalone test succeeds:

1. preserve the old development overlay as a local historical backup;
2. make the Git repository the authoritative source;
3. disable/remove the old `local-autodesk` repos.conf entry from active Portage resolution;
4. keep the old files temporarily if useful for comparison;
5. update docs to say the repository itself is authoritative.

Do not delete potentially useful original logs/payloads as part of repository productization.

The new normal environment should resolve:

```text
::maya-gentoo
```

rather than:

```text
::local-autodesk
```

---

# 34. Phase 29 — user-path smoke test

Follow the README **literally** as though the agent were a new user.

Do not use knowledge that is absent from README/INSTALL.

Verify that a competent Gentoo user could derive every required action from repository documentation.

Every time the agent catches itself relying on:

```text
old handoff knowledge
external work-tree paths
an undocumented command
a remembered package order
a hidden payload filename
```

fix the docs/tooling.

This phase ends only when the documented path is self-sufficient.

---

# 35. Phase 30 — Git commit structure

Make coherent commits rather than one giant dump.

Suggested progression:

```text
repo: add real Gentoo overlay metadata
app-autodesk/*: import tested Autodesk infrastructure packages
media-gfx/maya: import tested Maya 2027.2 package
media-gfx/*: import tested optional components
tools: productize Autodesk payload importer
tools: add preflight and verification helpers
docs: replace machine-specific install guide
docs: preserve 2027.2 validation and compatibility decisions
repo: add contributor/security guidance
qa: add repository validation tooling
```

Use current Gentoo-style package commit subjects where sensible.

Do not commit proprietary distfiles.

Run QA before every final commit series.

---

# 36. Phase 31 — remote publication behavior

Determine the configured `origin`.

If the repository has a writable configured remote and authentication is already available, push the completed commits after successful validation.

If push fails only because interactive Git-host authentication is unavailable, do **not** block the local technical completion or ask an unrelated question.

Leave:

```text
clean committed working tree
exact final commit hash
exact push command
```

If authentication can be completed safely through an existing GitHub/SSH flow without user secrets in chat, use it.

Do not force-push unless history was proven to contain an actual secret and H4 remediation requires history rewriting.

---

# 37. Success criteria

Do not declare completion until all required criteria are true.

```text
[ ] Repository root is a valid Gentoo ebuild repository.
[ ] Portage recognizes it as `maya-gentoo` or the chosen stable repo name.
[ ] profiles/repo_name exists.
[ ] profiles/categories correctly declares custom categories.
[ ] metadata/layout.conf is valid.
[ ] Every package has required metadata.xml.
[ ] Working Maya/Autodesk ebuilds are tracked in this Git repo.
[ ] Required `files/` assets/init scripts/wrappers are tracked.
[ ] Manifests for tested release are tracked and valid.
[ ] No Autodesk proprietary binary payload is tracked.
[ ] No credential/token/cookie/entitlement data is tracked.
[ ] Payload importer is inside the repository.
[ ] Importer consumes one official outer Autodesk archive.
[ ] Importer is independent of `/home/p2949` and the old work tree.
[ ] Release metadata/hashes for Maya 2027.2 are in the repository.
[ ] README contains a fresh-user Quick Start.
[ ] INSTALL documentation contains no original-machine dependency.
[ ] OpenRC path is correctly documented and remains tested.
[ ] systemd integration is packaged/documented accurately if implemented.
[ ] Compatibility fixes are documented and narrowly scoped.
[ ] `DISPLAY=:0` is not part of the permanent portable launch design.
[ ] Test-machine GPU/Mesa details are only evidence, not requirements.
[ ] Troubleshooting documentation covers the solved 2027.2 failures.
[ ] Maintainer/update workflow is documented.
[ ] QA tooling exists and passes.
[ ] The repository's importer reproduces expected distfiles from official archive.
[ ] `emerge --pretend` resolves Maya from the new repository.
[ ] Maya stack has been re-emerged from `::maya-gentoo`, not old `::local-autodesk`.
[ ] mayapy passes after repository migration.
[ ] Maya batch passes after repository migration.
[ ] GUI/Viewport 2.0 passes after repository migration.
[ ] clean Maya re-emerge passes from the repository.
[ ] Optional packaged components remain usable or accurately documented.
[ ] Old development overlay is no longer required for normal operation.
[ ] Git working tree is clean and committed.
```

---

# 38. Definition of “AUR-like” success for this project

For this goal, “like the AUR” does **not** mean copying Arch tooling.

It means the public workflow is approximately:

```text
add/clone community package repository
        ↓
download official proprietary upstream installer
        ↓
run one repository-provided payload import/preparation command
        ↓
Portage resolves dependencies and owns installation
        ↓
perform unavoidable Autodesk account authentication
        ↓
run `maya`
```

Users must not need:

```text
the original author's home directory
the original development overlay
private chat history
manual RPM installation
manual extraction of every RPM
knowledge of internal Autodesk package order
random symlink fixes from forum posts
global LD_LIBRARY_PATH
containers
VMs
```

The repository itself should carry the accumulated Gentoo-specific knowledge.

---

# 39. Final report

When complete, report concisely:

```text
repository final commit
repository remote/origin
tested Maya version
final repo tree summary
primary end-user install commands
packages included
importer command
QA result
standalone re-emerge result
mayapy/batch/GUI/Viewport results
optional component status
remaining documented limitations
whether remote push succeeded
```

Do not ask what to do next.

If a HUMAN INTERVENTION GATE is active, output only the exact required action for that gate and state that execution resumes automatically afterward.

---

# 40. Core principle

The successful machine is evidence.

The Git repository must become the product.

Anything necessary to understand, install, maintain, update, troubleshoot, or validate Maya on Gentoo should live in the repository **unless it is proprietary Autodesk payload, private account state, or ephemeral raw machine data**.

That is the definition of completion.
