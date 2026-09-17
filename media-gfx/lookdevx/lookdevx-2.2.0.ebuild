EAPI=8
RPM_COMPRESS_TYPE=xz
inherit rpm
DESCRIPTION="Autodesk LookdevX 2.2.0 for Maya 2027"
HOMEPAGE="https://www.autodesk.com/products/lookdevx/overview"
LICENSE="all-rights-reserved"
SLOT="2027"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip bindist"
RDEPEND="media-gfx/maya:2027"
SRC_URI="LookdevX-2.2.0-2027.el8.x86_64.rpm"
S=${WORKDIR}
src_unpack() { rpm_unpack; }
src_install() {
  dodir /usr/autodesk
  cp -a usr/autodesk/lookdevx "${D}/usr/autodesk/" || die
}
