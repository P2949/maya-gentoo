EAPI=8
inherit unpacker
DESCRIPTION="Autodesk ADP Desktop SDK"
HOMEPAGE="https://www.autodesk.com/"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch mirror strip bindist"
BDEPEND="app-arch/unzip"
RDEPEND="
  app-accessibility/at-spi2-core
  dev-libs/atk
  dev-libs/glib:2
  dev-libs/libpcre2
  dev-libs/libxml2
  x11-libs/cairo
  media-libs/fontconfig
  media-libs/freetype
  x11-libs/gdk-pixbuf
  media-libs/harfbuzz
  media-libs/libpng
  net-libs/libsoup:3.0
  net-misc/curl
  sys-apps/attr
  x11-libs/gtk+:3
  x11-libs/libX11
  x11-libs/libXrandr
  x11-libs/pango
  net-libs/webkit-gtk
"
SRC_URI="adp-desktop-sdk.zip"
S=${WORKDIR}
src_install() {
  insinto /opt/Autodesk/AdpDesktopSDK/bin
  doins -r .
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/ADPClientService
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/AdpSDKCore.so
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/AdpSDKUI.so
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/AdpSDKUtil
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/AdpSDKTools
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/libAdpIPC.so
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/libAdskIdentitySDK.so
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/libAdpSDKIdentityWrapper.so
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/ADPCER/senddmp
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/ADPCER/upi
  fperms 0755 /opt/Autodesk/AdpDesktopSDK/bin/ADPCER/libcer.so
}
