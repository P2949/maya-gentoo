# Native Autodesk Maya on Gentoo

This repository documents the tested native-Portage installation of Autodesk
Maya 2027.2 on Gentoo. Autodesk officially targets RHEL/Rocky Linux, so this
is an unsupported community packaging effort.

## Quick start

The configured public origin is:

    https://github.com/P2949/maya-gentoo.git

With eselect-repository:

    doas eselect repository add maya-gentoo git https://github.com/P2949/maya-gentoo.git
    doas emaint sync -r maya-gentoo

Or clone this repository and register the checkout in
/etc/portage/repos.conf/maya-gentoo.conf with repo-name maya-gentoo. Download
the official Autodesk archive, verify its hash, and import it:

    sha256sum ~/Downloads/Autodesk_Maya_2027_2_Update_Linux_64bit.tgz
    /var/db/repos/maya-gentoo/tools/import-autodesk-payload.sh \
      ~/Downloads/Autodesk_Maya_2027_2_Update_Linux_64bit.tgz

Then install and start licensing:

    doas emerge --ask media-gfx/maya
    doas rc-update add adsklicensing default
    doas rc-service adsklicensing start
    maya

Complete Autodesk sign-in/MFA only when Autodesk requests it. Optional
components can be emerged separately after base Maya is working.

## Start here

- [Portage installation guide](docs/PORTAGE_GUIDE.md)
- [Complete hand-off and validation record](MAYA_GENTOO_HANDOFF.md)
- [Original autonomous execution plan](NATIVE_MAYA_GENTOO_AUTONOMOUS_PLAN.md)
- [Artifact and evidence map](docs/ARTIFACTS_AND_EVIDENCE.md)

Tested payload:

```text
Autodesk_Maya_2027_2_Update_Linux_64bit.tgz
Maya 2027.2 build 1839
SHA-256 399250a3a2c306a403053da077221f7592170ca0d6196b8cbf2bfd17e25f94fe
```

After installation, launch with:

```bash
maya
```

The recipe uses a local Portage overlay, native OpenRC licensing, a scoped
XCB launcher, and Autodesk-private compatibility handling. It does not use a
container, VM, chroot, global `LD_LIBRARY_PATH`, global Qt/Python replacement,
Mesa replacement, OpenSSL downgrade, compiler-policy change, or boot change.

Autodesk payloads, RPMs, credentials, tokens, cookies, and entitlement data
are deliberately not included in Git.

The tested payload did not include matching Arnold/MtoA. MayaUSD, Bifrost,
LookdevX, and Substance were packaged separately.
