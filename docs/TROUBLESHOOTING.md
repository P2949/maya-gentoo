# Troubleshooting

## Maya exits with status 255 before licensing

Check the ADP SDK first:

    test -r /opt/Autodesk/AdpDesktopSDK/bin/AdpSDKCore.so

## Qt selects Wayland or aborts before the GUI

Use the repository launcher and confirm Xwayland is present. Do not set a
global Qt backend:

    env QT_QPA_PLATFORM=xcb GDK_BACKEND=x11 XDG_SESSION_TYPE=x11 maya

## TinputDeviceManager::createDeviceList crash

This was fixed in the tested package by a Maya-private empty libmd at
/usr/autodesk/maya2027/lib/libmd.so. Do not replace Gentoo's system libmd or
create a global SONAME symlink.

## Identity Manager curl 77 or status 3030

Check the Autodesk CA compatibility paths documented in the hand-off, then
inspect the Identity Manager log and Maya CLM log. Keep certificate behavior
scoped to Autodesk. Do not disable TLS verification.

## Login callback fails

Check both current-user handlers:

    xdg-mime query default x-scheme-handler/adskidmgr

The account holder must perform credentials/MFA/consent; never share tokens.

## Licensing service fails

    rc-service adsklicensing status
    tail -200 "$(ls -1t /usr/tmp/MayaCLM-*.log | head -1)"

Check service permissions and ELF dependencies before changing package files.

## Software-rendering concern

Inspect VP2.0 and glxinfo output. The tested result used AMD Mesa/radeonsi.
Do not install AMDGPU-PRO, replace Mesa, or export a global LD_LIBRARY_PATH.

The libtiff version-information and Mesa/Rusticl OpenCL warnings seen in the
tested setup were non-fatal.
