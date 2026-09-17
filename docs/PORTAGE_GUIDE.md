# Maya on Gentoo through Portage

This is the reproducible guide extracted from the completed installation.
Autodesk officially targets RHEL/Rocky Linux, not Gentoo.

## Tested payload

    Autodesk_Maya_2027_2_Update_Linux_64bit.tgz
    Maya 2027.2 build 1839
    SHA-256 399250a3a2c306a403053da077221f7592170ca0d6196b8cbf2bfd17e25f94fe

Download the official archive, preserve it unchanged, and verify it:

    sha256sum ~/Downloads/Autodesk_Maya_2027_2_Update_Linux_64bit.tgz

The repository's importer is:

    /var/db/repos/maya-gentoo/tools/import-autodesk-payload.sh \
      ~/Downloads/Autodesk_Maya_2027_2_Update_Linux_64bit.tgz

It discovers component sources, copies them to Portage DISTDIR, records maps
and hashes, and does not install anything. Never install Autodesk RPMs with
rpm -i, rpm -U, or rpm --force.

## Local overlay

The live repository is /var/db/repos/maya-gentoo and is registered with:

    [maya-gentoo]
    location = /var/db/repos/maya-gentoo
    masters = gentoo
    priority = 50

It contains account packages, Autodesk Licensing, Identity Manager, ADP
Desktop SDK, Maya, and separate MayaUSD/Bifrost/LookdevX/Substance packages.

After ebuild changes, regenerate Manifests, run pkgcheck, and perform a
Portage dry-run. Reject resolver plans that downgrade or replace glibc,
OpenSSL, Qt, Python, Mesa, the compiler, or the system C++ policy.

## Merge order

Merge account packages if required, then Licensing, Identity Manager, ADP
Desktop SDK, compatibility packages, Maya, and optional components:

    doas -n emerge --pretend --verbose \
      app-autodesk/adsk-licensing app-autodesk/adsk-identity-manager \
      app-autodesk/adp-desktop-sdk media-gfx/maya
    doas -n emerge \
      app-autodesk/adsk-licensing app-autodesk/adsk-identity-manager \
      app-autodesk/adp-desktop-sdk media-gfx/maya

Tested packages:

    media-gfx/maya-2027.2-r1
    app-autodesk/adsk-licensing-16.0.3.14414
    app-autodesk/adsk-identity-manager-1.18.1.2-r1
    app-autodesk/adp-desktop-sdk-6.3.34
    media-gfx/maya-usd-0.37.0
    media-gfx/bifrost-3.1.0.8
    media-gfx/lookdevx-2.2.0
    media-gfx/substance-maya-3.0.6

## Licensing and Identity Manager

    doas -n rc-update add adsklicensing default
    doas -n rc-service adsklicensing start
    rc-service adsklicensing status
    /opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list

Register Maya's product configuration and the desktop user's callback handler:

    doas -n emerge --config media-gfx/maya
    adsk-identity-register

The tested registration had feature MAYA, product key 657S1, product version
2027.0.0.F, user licensing method 4, cls_check_succ true, and authorize_succ
true. Derive values from the current payload for future releases.

Check callback handlers:

    xdg-mime query default x-scheme-handler/adskidmgr
    xdg-mime query default x-scheme-handler/adsk.idmgr

If credentials, MFA, consent, or EULA action is required, the account holder
must complete it in the secure Autodesk window. Never store credentials,
tokens, OAuth URLs, or cookies in Git. Inspect:

    /home/<user>/.local/share/Autodesk/Identity Services/Log/IdServices.log
    /usr/tmp/MayaCLM-16-09-2026.log

Successful evidence includes IsLoggedIn:true, Authorized, and
ADLSDK_STATUS_OK.

## ADP SDK and launcher

    test -r /opt/Autodesk/AdpDesktopSDK/bin/AdpSDKCore.so

For Wayland/Xwayland, the tested scoped launch is:

    env QT_QPA_PLATFORM=xcb GDK_BACKEND=x11 XDG_SESSION_TYPE=x11 maya

The installed wrapper also unsets WAYLAND_DISPLAY, WAYLAND_SOCKET, and
XDG_BACKEND, and exports the CA bundle only to Maya. Do not make these
settings global.

## Compatibility fixes

The original post-Qt/XCB/Mesa crash in TinputDeviceManager::createDeviceList()
was caused by Maya resolving Gentoo's incompatible system libmd. The Maya
package installs a private empty /usr/autodesk/maya2027/lib/libmd.so.

Autodesk's bundled networking code probed these Gentoo-missing certificate
paths:

    /etc/ssl/certs/ca-certificates.crt
    /etc/pki/tls/certs/ca-bundle.crt
    /usr/local/share/certs/ca-root-nss.crt
    /usr/local/cert.pem

The Maya wrapper selects the first readable path at runtime, preferring
Gentoo's maintained `/etc/ssl/certs/ca-certificates.crt`. None of the other
paths is created or owned by this overlay; they are compatibility locations
that may already exist on other distributions.

The libtiff version-information warning is non-fatal. Mesa/Rusticl may report
no AMD OpenCL device while Viewport 2.0 still uses AMD/Mesa OpenGL. Do not
replace Mesa or install AMDGPU-PRO for these messages.

## Validation

    rc-service adsklicensing status
    /opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list
    /usr/autodesk/maya2027/bin/mayapy -c 'import maya.standalone; maya.standalone.initialize(); print("MAYA_STANDALONE_OK"); maya.standalone.uninitialize()'
    /usr/bin/maya -batch -command 'print(about -version); quit -f'
    doas -n emerge -1 media-gfx/maya

The tested results were MAYA_STANDALONE_OK, version 2027, Authorized,
ADLSDK_STATUS_OK, and a clean re-emerge. VP2.0 reported AMD Radeon RX 9070 XT
(radeonsi), Mesa 26.2.0-devel, OpenGL 4.6. Raw automated output is not
redistributed; the validation result is recorded in the hand-off.

## Maintenance and safety

For a same-version reinstall:

    doas -n emerge -1 media-gfx/maya

For updates, import and hash the new official payload, derive versions and
registration from its metadata, update ebuilds, regenerate Manifests, run
pkgcheck, dry-run, merge in order, and repeat validation. Uninstall through
Portage and preserve /var/opt/Autodesk unless cleanup is deliberate.

Do not commit proprietary payloads or account data. Do not modify kernels,
initramfs, bootloaders, EFI/NVRAM, BootOrder, BootNext, /boot, or /efi.
