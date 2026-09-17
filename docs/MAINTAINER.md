# Maintainer workflow

For a new official Maya release:

1. Obtain the single official outer Linux installer.
2. Run the importer in inspection mode and record archive/component hashes.
3. Inspect RPM metadata, scripts, layouts, and dependencies.
4. Compare file layout and versions with the supported release.
5. Update releases metadata and ebuild versions.
6. Regenerate Manifests; never silently replace a changed upstream distfile.
7. Run tools/qa.sh, pkgcheck, and a Portage pretend.
8. Merge licensing, Identity, ADP, compatibility, Maya, and optional packages.
9. Validate registration, mayapy, batch, GUI, VP2, scene save/reopen, and clean
   re-emerge.
10. Update compatibility and validation documentation, then commit/tag.

Do not redistribute Autodesk files. Do not use the old development overlay as
an undocumented dependency. Preserve runtime licensing state while testing.
