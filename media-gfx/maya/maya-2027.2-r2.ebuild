EAPI=8
RPM_COMPRESS_TYPE=xz
inherit rpm xdg
DESCRIPTION="Autodesk Maya 2027 3D animation and visual effects software"
HOMEPAGE="https://www.autodesk.com/products/maya/overview"
LICENSE="all-rights-reserved"
SLOT="2027"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip bindist"
IUSE="opencl"
RDEPEND="
  app-autodesk/adsk-licensing
  app-autodesk/adsk-identity-manager
  app-autodesk/adp-desktop-sdk
  media-libs/mesa
  media-libs/libglvnd[X]
  x11-libs/libX11
  x11-libs/libxcb
  x11-libs/libXcursor
  x11-libs/libXext
  x11-libs/libXi
  x11-libs/libXinerama
  x11-libs/libXrandr
  x11-libs/libXrender
  x11-libs/libXt
  x11-libs/libXtst
  x11-libs/xcb-util-cursor
  x11-libs/xcb-util-image
  x11-libs/xcb-util-keysyms
  x11-libs/xcb-util-renderutil
  x11-libs/xcb-util-wm
  dev-libs/expat
  dev-libs/glib:2
  dev-libs/libxml2
  dev-libs/libxml2-compat
  dev-libs/openssl
  dev-libs/openssl-compat
  dev-libs/wayland
  app-crypt/mit-krb5
  media-libs/fontconfig
  media-libs/freetype[harfbuzz]
  media-libs/glew
  media-libs/libpng
  media-libs/tiff-compat
  sys-libs/zlib
  x11-libs/gtk+:3
  opencl? ( virtual/opencl )
"
SRC_URI="Maya2027_64-2027.2-1839.x86_64.rpm"
S=${WORKDIR}
src_unpack() { rpm_unpack; }
src_prepare() {
  # Maya's input-device startup code loads libmd by SONAME.  The host's
  # libmd is a different library and its constructors leave Maya in a null
  # callback path in TinputDeviceManager::createDeviceList().  An empty,
  # package-owned library at Maya's private lib root makes the bundled
  # launcher's private search path satisfy that lookup without changing the
  # host linker namespace.  This is the established Linux Maya workaround.
  : > usr/autodesk/maya2027/lib/libmd.so || die
    sed -i '/^export GDK_BACKEND=x11$/a\
   if [[ -n "${DISPLAY}" ]]; then\
       export QT_QPA_PLATFORM=xcb\
       export XDG_SESSION_TYPE=x11\
   fi' usr/autodesk/maya2027/bin/maya2027 || die
    # Identity Manager 1.18.1.2 may fall back to a Red Hat or FreeBSD CA
    # path. Select Gentoo's maintained bundle without requiring an unowned
    # compatibility file or symlink on a fresh host.
    sed -i '/^export GDK_BACKEND=x11$/a\
   unset WAYLAND_DISPLAY WAYLAND_SOCKET XDG_BACKEND\
   for adsk_ca in /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt /usr/local/share/certs/ca-root-nss.crt /usr/local/cert.pem; do\
       if [[ -r "${adsk_ca}" ]]; then\
           export SSL_CERT_FILE="${adsk_ca}"\
           export CURL_CA_BUNDLE="${adsk_ca}"\
           break\
       fi\
   done' usr/autodesk/maya2027/bin/maya2027 || die
    default
}
src_install() {
  # Autodesk ships a large mixed tree of executables, libraries, symlinks,
  # and data. Preserve the RPM modes and links while keeping ownership in
  # Portage's image; doins would flatten executable modes.
  if [[ -d opt/Autodesk ]]; then dodir /opt; cp -a opt/Autodesk "${D}/opt/" || die; fi
  if [[ -d usr/autodesk ]]; then dodir /usr; cp -a usr/autodesk "${D}/usr/" || die; fi
  if [[ -d usr/share ]]; then dodir /usr; cp -a usr/share "${D}/usr/" || die; fi
  if [[ -d var/opt ]]; then dodir /var; cp -a var/opt "${D}/var/" || die; fi
  if [[ -x usr/autodesk/maya2027/bin/maya2027 ]]; then dosym /usr/autodesk/maya2027/bin/maya2027 /usr/bin/maya; fi
  if [[ -x usr/autodesk/maya2027/bin/maya2027 ]]; then dosym maya2027 /usr/autodesk/maya2027/bin/maya; fi
  if [[ -f usr/autodesk/maya2027/resources/copyrights.txt ]]; then
    dodoc usr/autodesk/maya2027/resources/copyrights.txt
  fi
}
pkg_config() {
  local helper=/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper
  local pit=/var/opt/Autodesk/Adlm/Maya2027/MayaConfig.pit
  [[ -x ${helper} && -f ${pit} ]] || { ewarn "Maya registration deferred: licensing helper or MayaConfig.pit is unavailable"; return 0; }
  "${helper}" list | grep -q '657S1' || "${helper}" register --prod_key 657S1 --prod_ver 2027.0.0.F --config_file "${pit}" --eula_locale US
}
pkg_postinst() {
  # CER is a per-user service, but Autodesk's Linux payload hard-codes these
  # shared runtime roots.  Make only the required roots writable.
  install -d -m 1777 /var/lib/Autodesk /var/lib/Autodesk/CER
  install -d -m 1777 /usr/tmp
  elog "Run 'emerge --config media-gfx/maya' to register Maya with Autodesk Licensing."
  elog "As the desktop user, run 'adsk-identity-register' before browser sign-in."
}
