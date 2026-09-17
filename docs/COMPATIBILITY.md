# Compatibility matrix

| Release | Status | Init/session | Graphics | Optional payload | Workarounds |
| --- | --- | --- | --- | --- | --- |
| Maya 2027.2 build 1839 | tested on amd64 | OpenRC, Wayland + Xwayland/XCB | AMD Mesa/radeonsi; VP2 OpenGL 4.6 | MayaUSD, Bifrost, LookdevX, Substance packaged; Arnold absent from payload | private libmd, scoped XCB, CA paths |

The host used an AMD Radeon RX 9070 XT and Mesa 26.2.0-devel. These are
validation evidence, not hardware requirements. Autodesk officially supports
RHEL/Rocky rather than Gentoo; this repository is community-maintained.
