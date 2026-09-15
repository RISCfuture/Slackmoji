# Change Log

## [3.0.2] - 2026-09-14

### Changed

- Replaced the Quick and Nimble test dependencies with Swift Testing, so
  resolving this package no longer pulls them in
- Enabled the ImmutableWeakCaptures, MemberImportVisibility, ExistentialAny,
  and InternalImportsByDefault upcoming features
- Bumped swift-docc-plugin to 1.5.0 and swift-argument-parser to 1.8.2
- Building the test suite now needs Swift 6.2 or newer for its raw identifier
  test names; the library itself still builds with Swift 6.0

## [3.0.1] - 2026-06-26

### Changed

- Adopted the Approachable Concurrency upcoming features (NonisolatedNonsendingByDefault and InferIsolatedConformances)

## [3.0.0] - 2024-11-21

Emoji 15.0, version updates.

### Changed

- Updated to Emoji 15.0 standard
- Bumped OS versions and added other OSes

### Fixed

- Removed deprecations

## [2.0.0] - 2024-04-04

Locked down version requirements.

### Added

- Added DocC documentation

### Changed

- Updated to Emoji 15.1

## [1.2.0] - 2024-04-04

### Added

- Added DocC documentation

### Changed

- Updated to Emoji 15.1

## [1.1.0] - 2021-11-15

### Added

- `#messageWithShortcodesToEmoji`

## [1.0.1] - 2021-11-14

### Fixed

- Added public initializer

## [1.0.0] - 2021-11-10

Initial release.
