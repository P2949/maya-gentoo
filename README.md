# Native Autodesk Maya on Gentoo

This repository documents the tested native-Portage installation of Autodesk
Maya 2027.2 on Gentoo. Autodesk officially targets RHEL/Rocky Linux, so this
is an unsupported community packaging effort.

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
