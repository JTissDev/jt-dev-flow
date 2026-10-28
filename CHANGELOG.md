# Changelog

All notable changes to the `jtflow` utility will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-07-27

### Added
- Official initial release of `jtflow` CLI utility.
- Automated release command: `jtflow release`.
- Automated Java/Maven test execution runner (`mvn clean test`).
-  Dynamic `TODO`, `TOFIXX, and `FIXME` code scanner and cleaner module.
- Automated Git commit parser for dynamic `CHANGELOG.md  updates.
- Interactive Semantic Versioning engine supporting `pom.xml` version updates.
- Strict Git Flow release closure (``--no-ff`` merge, `vX.Y.Z` tagging, `-SNAPSHOT` initialization).