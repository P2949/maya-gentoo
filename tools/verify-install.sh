#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail
command -v qlist >/dev/null || { echo 'gentoolkit qlist is required' >&2; exit 1; }
qlist -Iv media-gfx/maya app-autodesk/adsk-licensing app-autodesk/adsk-identity-manager app-autodesk/adp-desktop-sdk
rc-service adsklicensing status 2>/dev/null || true
test -x /opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper
test -r /opt/Autodesk/AdpDesktopSDK/bin/AdpSDKCore.so
test -x /opt/Autodesk/AdskIdentityManager/Current/AdskIdentityManager
test -x /usr/autodesk/maya2027/bin/mayapy
test -x /usr/autodesk/maya2027/bin/maya.bin
echo 'AdskLicensingInstHelper:'
/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list | sed -n '1,80p'
echo 'Identity handler:'
xdg-mime query default x-scheme-handler/adskidmgr 2>/dev/null || true
/usr/autodesk/maya2027/bin/mayapy -c 'import maya.standalone; maya.standalone.initialize(); print("MAYA_STANDALONE_OK"); maya.standalone.uninitialize()'
/usr/bin/maya -batch -command 'print(`about -version`); quit -f'
