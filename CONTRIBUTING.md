# Contributing

Do not submit Autodesk RPMs, archives, binaries, account state, tokens,
cookies, or entitlement databases. Add release metadata and reproducible
ebuild/tool/documentation changes only.

Before submitting:

    tools/qa.sh
    pkgcheck scan --net none .

When reporting a failure, redact usernames, account identifiers, OAuth data,
and licensing databases. Include the release, package atom, command, and
relevant non-sensitive error signature. Use focused commits describing the
overlay, importer, QA, or documentation change.
