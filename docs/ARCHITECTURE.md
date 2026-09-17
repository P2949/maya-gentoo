# Architecture

The repository separates Autodesk Licensing, Identity Manager, ADP Desktop
SDK, compatibility packages, base Maya, and optional Maya components so that a
failure in an optional component cannot damage the base installation.

Autodesk RPMs and archives are upstream source inputs to ebuilds, never a
second package database. Portage owns installed static files. Compatibility
files stay private to Autodesk/Maya, protecting the Gentoo host ABI. The Maya
launcher scopes XCB, certificate, and related runtime behavior to Maya rather
than changing the desktop globally.

The result is a native host process using the host kernel, filesystem,
amdgpu/Mesa stack, and ordinary user home; no container or VM is involved.
