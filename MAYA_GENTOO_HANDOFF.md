# Autodesk Maya 2027.2 on Gentoo — Hand-off

Updated 2026-09-17. This document summarizes the completed autonomous goal
whose controlling specification is:

`/home/p2949/Desktop/maya/NATIVE_MAYA_GENTOO_AUTONOMOUS_PLAN.md`

## Final status

The installation is complete and validated. Maya 2027.2 build 1839 runs
directly as a Gentoo host process, launches through XCB/Xwayland, authenticates
with Autodesk, checks out the user license, initializes Viewport 2.0 on the
host AMD/Mesa stack, and passes batch, mayapy, scene, and clean re-emerge
validation.

No container, VM, chroot, Distrobox, Flatpak, Snap, alternate userspace,
global `LD_LIBRARY_PATH`, global Qt/Python replacement, Mesa replacement,
OpenSSL downgrade, compiler-policy change, kernel change, or boot/EFI change
was used.

## Locations

```text
Project root:        /home/p2949/Desktop/maya/
Execution work tree: /home/p2949/src/native-maya-gentoo/
State:               /home/p2949/src/native-maya-gentoo/STATE.md
Decisions:           /home/p2949/src/native-maya-gentoo/DECISIONS.md
Logs:                /home/p2949/src/native-maya-gentoo/logs/
Payload records:     /home/p2949/src/native-maya-gentoo/payload/
Test output:         /home/p2949/src/native-maya-gentoo/test-output/
Development overlay: /home/p2949/src/native-maya-gentoo/overlay-worktree/
Live overlay:        /var/db/repos/local-autodesk/
Maya:                /usr/autodesk/maya2027/
Launcher:            /usr/bin/maya
Autodesk components: /opt/Autodesk/
Runtime state:       /var/opt/Autodesk/
```

The live overlay is registered in
`/etc/portage/repos.conf/local-autodesk.conf`.

## Installed packages

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

The official payload did not contain a matching Arnold/MtoA component, so no
Arnold package was invented. Autodesk legacy ABI compatibility packages for
TIFF, libxml2, MIT Kerberos, and OpenSSL 1.1 are also Portage-managed; they do
not replace the host's current OpenSSL or C++ policy.

## Official payload

```text
Filename: Autodesk_Maya_2027_2_Update_Linux_64bit.tgz
Maya:     2027.2, build 1839
SHA-256:  399250a3a2c306a403053da077221f7592170ca0d6196b8cbf2bfd17e25f94fe
```

RPMs were extracted as ebuild sources and never installed into an RPM
database. Future payload imports use:

```bash
/home/p2949/src/native-maya-gentoo/scripts/import-autodesk-payload.sh \
  /path/to/Autodesk_Maya_<release>_Linux_64bit.tgz
```

Never commit Autodesk payloads, credentials, cookies, tokens, or entitlement
databases.

## Normal use

```bash
maya
```

The Portage-owned launcher applies these settings only to Maya:

```text
GDK_BACKEND=x11
QT_QPA_PLATFORM=xcb          (when DISPLAY is set)
XDG_SESSION_TYPE=x11         (when DISPLAY is set)
WAYLAND_DISPLAY unset
WAYLAND_SOCKET unset
XDG_BACKEND unset
SSL_CERT_FILE=/usr/local/cert.pem
CURL_CA_BUNDLE=/usr/local/cert.pem
```

The licensing service is native OpenRC:

```bash
rc-service adsklicensing status
rc-service adsklicensing start
```

## Licensing

Inspect registration with:

```bash
/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list
```

The validated registration has `feature_id=MAYA`,
`product key=657S1`, `product version=2027.0.0.F`,
`user_lic_enabled=true`, `cls_check_succ=true`,
`authorize_succ=true`, and user licensing method 4.

Final Maya evidence:

```text
LicenseUpdateCallback ... Authorized
adlsdkAuthorize: status ADLSDK_STATUS_OK
licenseProductName = Maya 2027
licenseUsageString = USAGE_USER
isTrialMode = False
```

Logs:

```text
/usr/tmp/MayaCLM-16-09-2026.log
/home/p2949/.local/share/Autodesk/Identity Services/Log/IdServices.log
```

The current-user callback association is checked with:

```bash
xdg-mime query default x-scheme-handler/adskidmgr
xdg-mime query default x-scheme-handler/adsk.idmgr
```

Never store credentials, MFA codes, OAuth URLs, tokens, or cookies in this
file. If sign-in is requested again, the account holder must complete it in
the secure Autodesk browser window.

## Problems solved

1. Qt initially selected Wayland and aborted. Maya now selects XCB and clears
   conflicting Wayland variables in its scoped launcher.
2. The post-Qt/XCB/Mesa crash in
   `TinputDeviceManager::createDeviceList()` was caused by Maya resolving
   Gentoo's incompatible `libmd`. A Maya-private empty
   `/usr/autodesk/maya2027/lib/libmd.so` fixes the collision.
3. Identity Manager curl 77/status 3030 was caused by Autodesk's bundled
   networking code probing missing Gentoo certificate paths. The compatibility
   paths are `/usr/local/cert.pem`,
   `/etc/pki/tls/certs/ca-bundle.crt`, and
   `/usr/local/share/certs/ca-root-nss.crt`.

The libtiff version-information warning and the Mesa/Rusticl OpenCL warning
are non-fatal. Viewport 2.0 uses the AMD/Mesa OpenGL stack.

## Validation

```bash
doas -n emerge -1 media-gfx/maya
```

The clean re-emerge completed. The old Vulkan headers removal emitted a
host optimization-hook framework-generation diagnostic, but Portage recovered
and completed both merges; it was unrelated to Maya.

```bash
/usr/autodesk/maya2027/bin/mayapy -c 'import maya.standalone; maya.standalone.initialize(); print("MAYA_STANDALONE_OK"); maya.standalone.uninitialize()'
# MAYA_STANDALONE_OK

/usr/bin/maya -batch -command 'print(`about -version`); quit -f'
# 2027
```

ADP is present at
`/opt/Autodesk/AdpDesktopSDK/bin/AdpSDKCore.so`.

Final GUI validation reached:

```text
Initialized VP2.0 renderer
Adapter: AMD Radeon RX 9070 XT (radeonsi, gfx1201, ACO)
Driver: Mesa 26.2.0-devel
API: OpenGL 4.6
```

Automated output:

```text
/home/p2949/src/native-maya-gentoo/test-output/native_smoke.ma
/home/p2949/src/native-maya-gentoo/test-output/render.log
```

## Git and maintenance

Overlay tip:

```text
1285726 fix Maya X11 authentication runtime
e8cb35a Fix Maya GUI libmd startup collision
8b845e1 Document tested Maya 2027.2 payload
c2b6444 Package LookdevX and Substance payloads
0e70c91 Package MayaUSD and Bifrost payload components
```

For the same payload, reinstall with `doas -n emerge -1 media-gfx/maya`.
For updates, import and hash the new official payload, derive versions and
registration data from its metadata, regenerate Manifests, run `pkgcheck`,
perform a dry-run, and repeat all runtime validation. Do not use `rpm -i`,
`rpm -U`, `rpm --force`, manual overwrites of Portage-owned files, or
global environment changes.

Do not modify kernels, initramfs, bootloaders, EFI variables, NVRAM,
`BootOrder`, `BootNext`, `/boot`, or `/efi` for Maya maintenance.

## Resume diagnostics

```bash
rc-service adsklicensing status
/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list
tail -200 /usr/tmp/MayaCLM-16-09-2026.log
tail -200 '/home/p2949/.local/share/Autodesk/Identity Services/Log/IdServices.log'
xdg-mime query default x-scheme-handler/adskidmgr
env DISPLAY=:0 QT_QPA_PLATFORM=xcb GDK_BACKEND=x11 \
  XDG_SESSION_TYPE=x11 /usr/bin/maya
```

Additional evidence is in `/home/p2949/src/native-maya-gentoo/logs/`,
`STATE.md`, `DECISIONS.md`, and the overlay
`README.md`.
