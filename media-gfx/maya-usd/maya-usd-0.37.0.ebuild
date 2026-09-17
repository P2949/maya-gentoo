EAPI=8
RPM_COMPRESS_TYPE=xz
inherit rpm
DESCRIPTION="Autodesk MayaUSD 0.37.0 for Maya 2027"
HOMEPAGE="https://github.com/Autodesk/maya-usd"
LICENSE="Apache-2.0"
SLOT="2027"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip"
RDEPEND="media-gfx/maya:2027"
SRC_URI="MayaUSD2027-202606101214-3bb5562-0.37.0-1.x86_64.rpm"
S=${WORKDIR}
src_unpack() { rpm_unpack; }
src_install() {
  dodir /usr/autodesk/mayausd
  cp -a usr/autodesk/mayausd/maya2027 "${D}/usr/autodesk/mayausd/" || die
}
