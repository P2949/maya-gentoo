EAPI=8
RPM_COMPRESS_TYPE=xz
inherit rpm
DESCRIPTION="Autodesk Identity Manager"
HOMEPAGE="https://www.autodesk.com/"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip bindist"
BDEPEND="dev-util/patchelf"
RDEPEND="net-libs/webkit-gtk:4.1[X]
  app-misc/ca-certificates"
SRC_URI="adskidentitymanager1.18.1.2-1.x86_64.rpm"
S=${WORKDIR}
src_unpack() { rpm_unpack; }

src_prepare() {
  default
  # Gentoo provides the current WebKitGTK 4.1 ABI. Rewrite the two obsolete
  # SONAMEs in the sole consumer instead of installing external compatibility
  # symlinks into the package image.
  patchelf --replace-needed \
    libwebkit2gtk-4.0.so.37 libwebkit2gtk-4.1.so.0 \
    opt/Autodesk/AdskIdentityManager/1.18.1.2/libIdServicesCore.so || die
  patchelf --replace-needed \
    libjavascriptcoregtk-4.0.so.18 libjavascriptcoregtk-4.1.so.0 \
    opt/Autodesk/AdskIdentityManager/1.18.1.2/libIdServicesCore.so || die
}

src_install() {
  dodir /opt/Autodesk/AdskIdentityManager/1.18.1.2
  cp -a opt/Autodesk/AdskIdentityManager/1.18.1.2/. \
    "${ED}/opt/Autodesk/AdskIdentityManager/1.18.1.2/" || die
  fperms 0755 /opt/Autodesk/AdskIdentityManager/1.18.1.2/AdskIdentityManager
  dosym /opt/Autodesk/AdskIdentityManager/1.18.1.2 /opt/Autodesk/AdskIdentityManager/Current
  newbin "${FILESDIR}/adsk-identity-register" adsk-identity-register
}
