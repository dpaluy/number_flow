# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2026-07-26

### Changed
- Updated GitHub Actions checkout to v7 and browser-actions/setup-chrome to v2.
- Updated Rake to 13.4.2, Minitest to 6.0.6, IRB to 1.18.0, and the Rails dependency set (including Action View and Railties) to 8.1.3.
- Refreshed the lockfile against the combined dependency updates before release preparation.

## [0.2.0] - 2026-07-13

### Added
- Decimal and fractional number animations with configurable precision and rollover behavior.
- Locale-aware number formatting powered by `Intl.NumberFormat`.
- Optional `NumberFlow::Component` integration and a Vite installer generator.
- Chromium/Cuprite browser coverage and continuous integration for browser behavior.

### Changed
- Improved negative-number and reduced-motion animation behavior.
- Documented the decision to keep Number Flow distributed as a Ruby gem.

## [0.1.2] - 2026-07-12

### Changed
- Updated Rails-related lockfile dependencies, RuboCop, and Minitest.

## [0.1.1] - 2026-07-12

### Changed
- Updated the Action View dependency to 8.1.2.1.

## [0.1.0] - 2026-02-23

### Added
- Initial release of `number_flow`.
- Rails helper API: `number_flow_tag`.
- Rails engine integration for helper and assets.
- Stimulus controller and CSS assets shipped inside the gem.
- Minitest suite for helper and integration contracts.

