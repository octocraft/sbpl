# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Add more details to error messages
### Changed
- Fix clean command

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

[Unreleased]: https://github.com/octocraft/sbpl/compare/master...dev
[0.2.0]: https://github.com/octocraft/sbpl/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/octocraft/sbpl/tree/v0.1.0
