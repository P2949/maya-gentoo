EAPI=8
RPM_COMPRESS_TYPE=xz
inherit rpm
DESCRIPTION="Autodesk Bifrost 3.1.0.8 for Maya 2027"
HOMEPAGE="https://www.autodesk.com/products/bifrost/overview"
LICENSE="all-rights-reserved"
SLOT="2027"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip"
RDEPEND="media-gfx/maya:2027"
SRC_URI="Bifrost2027-3.1.0.8-3.1.0.8-1.x86_64.rpm"
S=${WORKDIR}
src_unpack() { rpm_unpack; }
src_install() {
  dodir /usr/autodesk
  cp -a usr/autodesk/ApplicationPlugins usr/autodesk/bifrost "${D}/usr/autodesk/" 2>/dev/null || true
  if [[ -d opt/Autodesk ]]; then dodir /opt; cp -a opt/Autodesk "${D}/opt/" || die; fi
}
