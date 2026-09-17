# Installation

This is the canonical concise installation path for the public
`maya-gentoo` repository. The deeper operational notes are in
[PORTAGE_GUIDE.md](PORTAGE_GUIDE.md).

1. Add this checkout as the `maya-gentoo` repository, or install the released
   repository under `/var/db/repos/maya-gentoo`.
2. In `/etc/portage`, accept the overlay's unstable amd64 keywords, proprietary
   licence, and GUI USE flags:

       **/**::maya-gentoo ~amd64
       **/**::maya-gentoo all-rights-reserved
       x11-libs/cairo X
       media-libs/libglvnd X
       media-libs/freetype harfbuzz
       net-libs/webkit-gtk X
       media-libs/gst-plugins-base opengl
       media-libs/harfbuzz icu

3. Obtain the Autodesk archive through an Autodesk account. Do not place the
   archive, credentials, or extracted proprietary files in Git.
4. Import the archive with `tools/import-autodesk-payload.sh`. The importer
   verifies the release hash and places accepted distfiles in Portage's
   configured `DISTDIR`.
5. This release supports OpenRC licensing integration only. Install Maya,
   enable and start licensing, register Maya's product configuration, and
   register the desktop callback:

       doas emerge --ask media-gfx/maya
       doas rc-update add adsklicensing default
       doas rc-service adsklicensing start
       doas emerge --config media-gfx/maya
       adsk-identity-register
       maya

   Complete Autodesk sign-in/MFA when requested. If the helper reports exit
   124, it installed the callback but Autodesk's upstream registration process
   remained resident for 30 seconds; verify
   `xdg-mime query default x-scheme-handler/adskidmgr` and continue.

The ebuilds are restricted and require the exact distfiles named by the
release metadata. An Autodesk license and network access are still required;
this repository does not provide either one.
