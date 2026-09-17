# Implementation decisions

- The Maya launcher selects XCB when a display is available and removes
  conflicting Wayland variables from the child process. This keeps the fix
  scoped to Maya rather than changing the user's desktop session.
- Maya's private `libmd.so` is supplied as an empty compatibility library;
  this prevents the known input-device startup crash while leaving the system
  library set untouched.
- Autodesk's bundled certificate lookup is supplemented with common Gentoo
  CA-bundle paths. No certificate bypass or insecure TLS setting is used.
- Proprietary archives remain outside Git. The importer is the reproducible
  boundary between a user-provided Autodesk archive and Portage's `DISTDIR`.
- OpenRC is the tested service integration. No systemd unit is shipped or
  represented as tested by this repository.
