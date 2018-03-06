# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- test command for testing with bats
- prevent double root dir
### Changed
- Indicate progress while downloading
- Lock current dirs to actual OS/ARCH
- remove fallback from zip (bug in fallback)

## [0.4.0] - 2018-03-03
### Added
- get command to download packages from shell
- Integration testing on OSX
- Indicate OS/ARCH while downloading packages
- Make packages and binaries accessible via current dir
- use wget or curl (whatever is available)
- vars to indicate actual OS/ARCH
- fall back to archiver if un* is unavailbe
### Changed
- bin dir include and filter
- fix empty bin dir variable
- rename OS/ARCH to sbpl_os/sbpl_arch
- use un* to extract archives

## [0.3.0] - 2018-02-26
### Added
- Package locking
### Changed
- Fix clean command
- Improved error handling

## [0.2.0] - 2018-02-24
### Added
- CHANGELOG.md
- CONTRIBUTING.md
- envvar command to access sbpl variables
### Changed
- package dir moved from "vendor/$pkgname-$version-$OS-$ARCH" to "vendor/$OS/$ARCH/$pkgname-$version"
- Updated Examples to use envvars command to retrive bin dir 
- Renamed sbpl variables to more consistent naming scheme
- Working dir changed from sbpl.sh base dir to pwd

## [0.1.0] - 2018-02-21
### Added
- Initial

[Unreleased]: https://github.com/octocraft/sbpl/compare/master...v0.4.0
[0.4.0]: https://github.com/octocraft/sbpl/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/octocraft/sbpl/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/octocraft/sbpl/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/octocraft/sbpl/tree/v0.1.0
