EAPI=8
RPM_COMPRESS_TYPE=xz
inherit rpm
DESCRIPTION="Autodesk Licensing Framework"
HOMEPAGE="https://www.autodesk.com/"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip bindist"
RDEPEND="acct-group/adsklic acct-user/adsklic"
SRC_URI="adsklicensing16.0.3.14414-0-0.x86_64.rpm"
S=${WORKDIR}
src_unpack() { rpm_unpack; }
src_install() {
  dodir /opt/Autodesk/AdskLicensing
  cp -a opt/Autodesk/AdskLicensing/16.0.3.14414 "${D}/opt/Autodesk/AdskLicensing/" || die
  while IFS= read -r -d '' f; do
    if file -b "${f}" | grep -q 'ELF'; then chmod 0755 "${D}/${f#./}"; fi
  done < <(find ./opt/Autodesk/AdskLicensing/16.0.3.14414 -type f -print0)
  dosym /opt/Autodesk/AdskLicensing/16.0.3.14414 /opt/Autodesk/AdskLicensing/Current
  dosym /opt/Autodesk/AdskLicensing/16.0.3.14414/AdskLicensingService/AdskLicensingService /usr/bin/AdskLicensingService
  newinitd "${FILESDIR}/adsklicensing.openrc" adsklicensing
}
pkg_postinst() {
  # Reproduce the writable runtime tree created by Autodesk's RPM %post.
  # Keep it outside the image so the service account owns only its state.
  install -d -o adsklic -g adsklic -m 0755 /var/opt/Autodesk
  install -d -o adsklic -g adsklic -m 0775 /var/opt/Autodesk/AdskLicensingService
  install -d -o adsklic -g adsklic -m 0775 /var/opt/Autodesk/AdskLicensingService/Log
}
