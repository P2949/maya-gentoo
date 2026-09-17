# Portage work artifact map

The repository itself is now the authoritative public implementation. The
original validation work tree is retained only as historical evidence on the
tested host and is not required by users.

| Purpose | Authoritative location |
| --- | --- |
| Release metadata | `releases/2027.2/release.json` |
| Payload importer | `tools/import-autodesk-payload.sh` |
| Preflight/verification/QA | `tools/preflight.sh`, `tools/verify-install.sh`, `tools/qa.sh` |
| Package source | `acct-*`, `app-autodesk/`, `media-gfx/` |
| OpenRC service | `app-autodesk/adsk-licensing/files/adsklicensing.openrc` |
| Validation record | `MAYA_GENTOO_HANDOFF_2026-09-17.md` and `docs/TESTING.md` |
| Compatibility decisions | `docs/COMPATIBILITY.md`, `docs/TROUBLESHOOTING.md` |
| Architecture | `docs/ARCHITECTURE.md` |

Final overlay commits:

    0e70c91  Package MayaUSD and Bifrost payload components
    c2b6444  Package LookdevX and Substance payloads
    8b845e1  Document tested Maya 2027.2 payload
    e8cb35a  Fix Maya GUI libmd startup collision
    1285726  fix Maya X11 authentication runtime

The old overlay is not needed for normal operation. Never copy RPMs, ZIPs,
TGZs, extracted Autodesk trees, license databases, or browser/account data
into this repository.
