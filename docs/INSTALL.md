# Installation

This is the short installation path for the public `maya-gentoo` repository.
The longer operational notes are in [PORTAGE_GUIDE.md](PORTAGE_GUIDE.md).

1. Add this checkout as the `maya-gentoo` repository, or install the released
   repository under `/var/db/repos/maya-gentoo`.
2. Obtain the Autodesk archive through an Autodesk account. Do not place the
   archive, credentials, or extracted proprietary files in Git.
3. Import the archive with `tools/import-autodesk-payload.sh`. The importer
   verifies the release hash and places accepted distfiles in Portage's
   configured `DISTDIR`.
4. Install the core package with `emerge --ask media-gfx/maya`.
5. Enable the packaged OpenRC licensing service when the host uses OpenRC,
   then launch Maya through the installed wrapper.

The ebuilds are restricted and require the exact distfiles named by the
release metadata. An Autodesk license and network access are still required;
this repository does not provide either one.
