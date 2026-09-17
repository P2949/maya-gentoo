EAPI=8
RPM_COMPRESS_TYPE=xz
inherit rpm
DESCRIPTION="Adobe Substance 3D for Maya 3.0.6"
HOMEPAGE="https://www.adobe.com/products/substance3d/apps/plugins/substance-3d-plugin-for-maya.html"
LICENSE="all-rights-reserved"
SLOT="2027"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip"
RDEPEND="media-gfx/maya:2027"
SRC_URI="AdobeSubstance3DforMaya-3.0.6-2027-linux-x86_64.rpm"
S=${WORKDIR}
src_unpack() { rpm_unpack; }
src_install() {
  dodir /opt/Allegorithmic
  cp -a opt/Allegorithmic/Substance_in_Maya "${D}/opt/Allegorithmic/" || die
}
