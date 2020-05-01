# Changelog

## [0.4.2] 2020-05-01
### Added:
- Moved to new
 - Thats to: [@jonjohnston](https://gitub.com/jonjohnston)

## [0.4.1] 2020-02-25
### Added:
- Pipenv support
 - Thanks to: [@jrisebor](https://github.com/jrisebor)

### Fixed:
- Minor typo
 - Thanks to: [@dx-pbuckley](https://github.com/dx-pbuckley)
- App link handling in MFA flow.
 - Thanks to: [@iress-james-bowe](https://github.com/iress-james-bowe)
- Handling of missing default profile. (#57)
 - Thanks to: [@jrisebor](https://github.com/jrisebor)

## [0.4.0] 2019-04-14
### Added:
- Per-application multi-factor authentication support
 - Thanks to: [@nonspecialist](https://github.com/nonspecialist)
### Fixed:
- Invalid SAML assertion when per-app MFA is used. (#36)

## [0.3.1] 2019-03-04
### Added:
- Skip app prompt if there's only one to choose from.
  - Thanks to: [@mcstafford-git](https://github.com/mcstafford-git)
### Fixed:
- Removed setting region and output format in AWS credentials file. (#72)
  - Thanks to: [@jrisebor](https://github.com/jrisebor)

## [0.3.0] 2018-12-10
### Added:
- Ability to set requested token duration. (#43).
  - Thanks to: [@arahayrabedian](https://github.com/arahayrabedian)
- FIDO U2F support.
  - Thanks to: [@guerremdq](https://github.com/guerremdq) & [@savar](https://github.com/savar)

## [0.2.5] 2018-10-18
### Added:
- Ability to store AWS App choice in `~/.okta-aws`. (#12)

### Fixed:
- List of AWS roles returns properly now. (#45)

## [0.2.4] 2018-09-03
### Fixed:
- Casting issue with MFA factor selection. (#44)

## [0.2.3] 2018-07-21
### Added:
- Travis CI builds to run linting tests for branches and PRs.

### Fixed:
- Python3 Compatibility issues.

## [0.2.2] 2018-07-18
### Fixed:
- Python3 Compatibility. (#38)

## [0.2.1] 2018-02-14
### Fixed:
- Issue where secondary auth would fail when only a single factor is enrolled for the user. (#27)

## [0.2.0] 2018-02-11
### Added:
- Ability to store MFA factor choice in `~/.okta-aws`. (#3)
- Flag to output the version.
- Ability to store AWS Role choice in `~/.okta-aws`. (#4)
- Ability to pass in TOTP token as a command-line argument. (#13)
- Support for MFA push notifications. Thanks Justin! (#10)
- Support for caching credentials to use in other sessions. Thanks Justin! (#6, #7)

### Fixed:
- Issue #14. Fixed a bug where okta-awscli wasn't connecting to the STS API endpoint in us-gov-west-1 when trying to obtain credential for GovCloud.
- Improved sorting in the app list to be more consistent. Thanks Justin!
- Cleaned up README to improve clarity. Thanks Justin!

## [0.1.5] 2017-11-15
### Fixed:
- Issue #8. Another pass at trying to fix the MFA list. Factor chosen was being pulled from list which included unsupported factors.

## [0.1.4] 2017-08-27
### Added:
- This CHANGELOG!

### Fixed:
- Issue #1. Bug where MFA factor selected isn't always the one passed to Okta for verification.


## [0.1.3] 2017-08-17
### Added:
- Prompts for a username and password if omitted from `.okta-aws`

### Changed:
- Spelling fix
- Change `--okta_profile` flag to be `--okta-profile` instead.


## [0.1.2] 2017-07-25
### Added:
- Support for flag to force new credentials.

### Changed
- Handles no profile provided.
- Handles no awscli args provided (authenticate only).


## [0.1.1] 2017-07-25
- Initial release. Updated for PyPi.
