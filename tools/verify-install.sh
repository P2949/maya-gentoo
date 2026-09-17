#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail
command -v qlist >/dev/null || { echo 'gentoolkit qlist is required' >&2; exit 1; }
qlist -Iv media-gfx/maya app-autodesk/adsk-licensing app-autodesk/adsk-identity-manager app-autodesk/adp-desktop-sdk
rc-service adsklicensing status
test -x /opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper
test -r /opt/Autodesk/AdpDesktopSDK/bin/AdpSDKCore.so
test -x /opt/Autodesk/AdskIdentityManager/Current/AdskIdentityManager
test -x /usr/autodesk/maya2027/bin/mayapy
test -x /usr/autodesk/maya2027/bin/maya.bin
for atom in app-autodesk/adsk-licensing app-autodesk/adsk-identity-manager app-autodesk/adp-desktop-sdk media-gfx/maya; do
  cpv=$(qlist -Iv "$atom" | awk 'NR==1 {print $1}')
  repo=$(<"/var/db/pkg/${cpv}/repository")
  [[ ${repo} == maya-gentoo ]] || { echo "wrong repository for ${cpv}: ${repo}" >&2; exit 1; }
done
old_needed=$(patchelf --print-needed /opt/Autodesk/AdskIdentityManager/Current/libIdServicesCore.so)
grep -qx 'libwebkit2gtk-4.1.so.0' <<<"${old_needed}" || { echo 'Identity Manager WebKitGTK SONAME is not patched' >&2; exit 1; }
grep -qx 'libjavascriptcoregtk-4.1.so.0' <<<"${old_needed}" || { echo 'Identity Manager JavaScriptCore SONAME is not patched' >&2; exit 1; }
echo 'AdskLicensingInstHelper:'
/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list | sed -n '1,80p'
echo 'Identity handler:'
handler=$(xdg-mime query default x-scheme-handler/adskidmgr)
[[ -n ${handler} && ${handler} == *AdskIdentityManager* ]] || { echo "Autodesk callback handler is not registered: ${handler}" >&2; exit 1; }
/usr/autodesk/maya2027/bin/mayapy -c 'import maya.standalone; maya.standalone.initialize(); print("MAYA_STANDALONE_OK"); maya.standalone.uninitialize()'
/usr/bin/maya -batch -command 'print(`about -version`); quit -f'
