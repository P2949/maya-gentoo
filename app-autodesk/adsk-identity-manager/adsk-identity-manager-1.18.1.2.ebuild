EAPI=8
RPM_COMPRESS_TYPE=xz
inherit rpm
DESCRIPTION="Autodesk Identity Manager"
HOMEPAGE="https://www.autodesk.com/"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip"
RDEPEND="net-libs/webkit-gtk
  app-misc/ca-certificates"
SRC_URI="adskidentitymanager1.18.1.2-1.x86_64.rpm"
S=${WORKDIR}
src_unpack() { rpm_unpack; }
src_install() {
  insinto /opt/Autodesk/AdskIdentityManager/1.18.1.2
  doins -r opt/Autodesk/AdskIdentityManager/1.18.1.2/*
  # The Autodesk binary uses the WebKitGTK 4.0 sonames.  Gentoo's current
  # WebKitGTK slot exposes the compatible 4.1 libraries; keep the mapping
  # private to Identity Manager rather than adding global linker aliases.
  dosym /usr/lib64/libwebkit2gtk-4.1.so.0 /opt/Autodesk/AdskIdentityManager/1.18.1.2/libwebkit2gtk-4.0.so.37
  dosym /usr/lib64/libjavascriptcoregtk-4.1.so.0 /opt/Autodesk/AdskIdentityManager/1.18.1.2/libjavascriptcoregtk-4.0.so.18
  fperms 0755 /opt/Autodesk/AdskIdentityManager/1.18.1.2/AdskIdentityManager
  dosym /opt/Autodesk/AdskIdentityManager/1.18.1.2 /opt/Autodesk/AdskIdentityManager/Current
}
