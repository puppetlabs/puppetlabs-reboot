# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v4.0.2](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.0.2) (2021-03-19)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v4.0.1...v4.0.2)

### Fixed

- \(MODULES-10963\) remove win32-process on Puppet 7 [\#287](https://github.com/puppetlabs/puppetlabs-reboot/pull/287) ([gimmyxd](https://github.com/gimmyxd))

## [v4.0.1](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.0.1) (2021-03-15)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v4.0.0...v4.0.1)

### Fixed

- Cleanup: Changed to ctrl::sleep\(\) and removed redundant reboot::sleep\(\) function [\#284](https://github.com/puppetlabs/puppetlabs-reboot/pull/284) ([fetzerms](https://github.com/fetzerms))
- \(MODULES-10955\) More robust handling of reboot-task output [\#280](https://github.com/puppetlabs/puppetlabs-reboot/pull/280) ([fetzerms](https://github.com/fetzerms))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.0.0) (2021-02-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v3.2.0...v4.0.0)

### Changed

- pdksync - \(MAINT\) Remove SLES 11 support [\#279](https://github.com/puppetlabs/puppetlabs-reboot/pull/279) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - \(MAINT\) Remove RHEL 5 family support [\#278](https://github.com/puppetlabs/puppetlabs-reboot/pull/278) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [\#275](https://github.com/puppetlabs/puppetlabs-reboot/pull/275) ([carabasdaniel](https://github.com/carabasdaniel))

## [v3.2.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v3.2.0) (2021-01-19)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v3.1.0...v3.2.0)

### Added

- pdksync - \(feat\) Add support for Puppet 7 [\#265](https://github.com/puppetlabs/puppetlabs-reboot/pull/265) ([daianamezdrea](https://github.com/daianamezdrea))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v3.1.0) (2020-11-17)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v3.0.0...v3.1.0)

### Added

- pdksync - \(IAC-973\) - Update travis/appveyor to run on new default branch `main` [\#253](https://github.com/puppetlabs/puppetlabs-reboot/pull/253) ([david22swan](https://github.com/david22swan))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v3.0.0) (2020-02-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v2.4.0...v3.0.0)

### Changed

- \(GH-1376\) Change `$nodes` parameter for `reboot` plan to `$targets` [\#223](https://github.com/puppetlabs/puppetlabs-reboot/pull/223) ([beechtom](https://github.com/beechtom))

## [v2.4.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v2.4.0) (2020-02-03)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v2.3.0...v2.4.0)

### Added

- Add `shutdown_only` parameter to tasks [\#224](https://github.com/puppetlabs/puppetlabs-reboot/pull/224) ([MikaelSmith](https://github.com/MikaelSmith))
- \(MODULES-8201\) Add pending reboot due to domain join for windows. [\#179](https://github.com/puppetlabs/puppetlabs-reboot/pull/179) ([razorbladex401](https://github.com/razorbladex401))

## [v2.3.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v2.3.0) (2019-12-06)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/2.2.0...v2.3.0)

### Added

- \(FM-8700\) - Addition of Support for CentOs 8 [\#221](https://github.com/puppetlabs/puppetlabs-reboot/pull/221) ([david22swan](https://github.com/david22swan))
- pdksync - Add support on Debian10 [\#218](https://github.com/puppetlabs/puppetlabs-reboot/pull/218) ([lionce](https://github.com/lionce))

### Fixed

- Fix reboot message for linux hosts [\#213](https://github.com/puppetlabs/puppetlabs-reboot/pull/213) ([nmaludy](https://github.com/nmaludy))

## [2.2.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/2.2.0) (2019-07-24)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v2.2.0...2.2.0)

## [v2.2.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v2.2.0) (2019-07-24)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/2.1.2...v2.2.0)

### Added

- Fix plan return value [\#209](https://github.com/puppetlabs/puppetlabs-reboot/pull/209) ([reidmv](https://github.com/reidmv))
- \(FM-8051\) Add RedHat 8 support [\#207](https://github.com/puppetlabs/puppetlabs-reboot/pull/207) ([eimlav](https://github.com/eimlav))
- MODULES-8726: Ensure sbin is in the path [\#205](https://github.com/puppetlabs/puppetlabs-reboot/pull/205) ([xalimar](https://github.com/xalimar))
- \(MODULES-8148\) - Add SLES 15 support [\#191](https://github.com/puppetlabs/puppetlabs-reboot/pull/191) ([eimlav](https://github.com/eimlav))

### Fixed

- Add additional guards for nix process detach [\#210](https://github.com/puppetlabs/puppetlabs-reboot/pull/210) ([reidmv](https://github.com/reidmv))
- \[MODULES-8718\] Check for root or sudo in the reboot task nix.sh script [\#203](https://github.com/puppetlabs/puppetlabs-reboot/pull/203) ([thilinapiy](https://github.com/thilinapiy))
- \(MODULES-8717\) Fix dependency issue on boltspec [\#202](https://github.com/puppetlabs/puppetlabs-reboot/pull/202) ([HelenCampbell](https://github.com/HelenCampbell))

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]


## [2.1.2] - 2018-12-13
### Fixed
- Fix infinite reboot plan wait loop on Windows when reboot takes under a minute ([MODULES-8353](https://tickets.puppetlabs.com/browse/MODULES-8353))
- Mark last_boot_time task implementations as private so they're not listed by Bolt.

## [2.1.1] - 2018-12-06
### Added
- Use wait_until_available to reduce task runs ([BOLT-956](https://tickets.puppetlabs.com/browse/BOLT-956))
- Add bash and powershell implementations of reboot task ([BOLT-459](https://tickets.puppetlabs.com/browse/BOLT-459))
- Support for Puppet 6 ([MODULES-7832](https://tickets.puppetlabs.com/browse/MODULES-7832))
- Add Rubocop to enforce PDK rules ([MODULES-5896](https://tickets.puppetlabs.com/browse/MODULES-5896))
- Add Beaker Testmode Switcher ([MODULES-6745](https://tickets.puppetlabs.com/browse/MODULES-6745))
- Add acceptance-test support for Debian 9, Ubuntu 16.04 and Ubuntu 18.04 ([MODULES-7417](https://tickets.puppetlabs.com/browse/MODULES-7417))

### Changed
- Update limitations in README ([MODULES-7634](https://tickets.puppetlabs.com/browse/MODULES-7634))
- Convert module to PDK format ([MODULES-7403](https://tickets.puppetlabs.com/browse/MODULES-7403))
- Use Beaker 4 ([MODULES-7658](https://tickets.puppetlabs.com/browse/MODULES-7658))

### Fixed
- Fix conditionals in Windows provider ([MODULES-3975](https://tickets.puppetlabs.com/browse/MODULES-3975))

### Removed
- Support for SLES 5 and Debian 7 ([FM-6968](https://tickets.puppetlabs.com/browse/FM-6968))

### Security
- Fix [CVE-2018-6508](https://nvd.nist.gov/vuln/detail/CVE-2018-6508)

## [2.0.0] - 2018-01-23
### Added
- Support for Puppet 5
- Add a [Puppet Task](https://puppet.com/docs/bolt/0.x/running_tasks_and_plans_with_bolt.html#concept-1376) for performing on-demand reboots ([MODULES5804](https://tickets.puppetlabs.com/browse/MODULES-5804))
- Add capability to reboot a Windows machine if [specific conditions](https://github.com/puppetlabs/puppetlabs-reboot#onlyif) are met via the `onlyif` parameter ([MODULES-4328](https://tickets.puppetlabs.com/browse/MODULES-4328))
- Add capability to prevent a reboot resource from rebooting a Windows machine if [specific conditions](https://github.com/puppetlabs/puppetlabs-reboot#unless) are met via the `unless` parameter ([MODULES-4328](https://tickets.puppetlabs.com/browse/MODULES-4328))

### Fixed
- Converted test framework from Beaker to Beaker-RSpec ([MODULES-5977](https://tickets.puppetlabs.com/browse/MODULES-5977))

### Removed
- Ended support for Puppet 3

## [1.2.1] - 2015-11-24
### Added
- Pending reboot - Allow setting a flag directly on provider ([MODULES-2822](https://tickets.puppet.com/browse/MODULES-2822))

### Changed
- Fix use of read method from Registry ([MODULES-2804](https://tickets.puppet.com/browse/MODULES-2804))

## [1.2.0] - 2015-10-14
### Added
- Pending reboot - detect computer rename ([MODULES-2657](https://tickets.puppet.com/browse/MODULES-2657))
- Pending reboot - Detect DSC pending reboot state ([MODULES-2658](https://tickets.puppet.com/browse/MODULES-2658))
- Pending reboot - Detect CCM pending reboot state ([MODULES-2659](https://tickets.puppet.com/browse/MODULES-2659))

### Changed
- Fix Linux provider failing ([MODULES-2585](https://tickets.puppet.com/browse/MODULES-2585))

## [1.1.0] - 2015-07-28 - Supported Release 1.1.0
### Added
- Add notice when system is scheduling a reboot

### Changed
- Move Linux provider to use new POSIX provider
- Fix Unit and Acceptance Test cases

## [1.0.0] - 2015-04-15
### Added
- Linux support

### Changed
- Reboot is now triggered `at_exit` instead of watching for ruby process to end

### Removed
- Prompt for windows reboot
- `catalog_apply_timeout` parameter

## [0.1.9] - 2014-11-11
### Changed
- Fixes issues URL in metadata

## [0.1.8] - 2014-08-25
### Changed
- Fixes for working on x64-native ruby.

## [0.1.7] - 2014-07-15
### Changed
 - Update `metadata.json` so the module can be uninstalled and upgraded via the `puppet module` command.

## [0.1.6] - 2014-04-15
### Changed
- Updated metadata.

## [0.1.5] - 2014-03-04
### Added
- The version is `0.x` but should be considered a `1.x` for semantic versioning purposes.

---

## [0.1.4] - 2014-02-07
### Changed
- Add a workaround for a ruby bug that can prevent ruby.exe from exiting ([PUP-1578](https://tickets.puppetlabs.com/browse/PUP-1578))

## [0.1.2] - 2013-09-27
### Changed
- Never load sample.pp in production

## [0.1.1] - 2013-09-27
###
- Only manage reboot resources on systems where shutdown.exe exists ([FM-105](https://tickets.puppetlabs.com/browse/FM-105))
- Module does not work on Windows 2003 ([FM-106](https://tickets.puppetlabs.com/browse/FM-106))
- Update description in init.pp ([PP-433](https://tickets.puppetlabs.com/browse/PUP-433))

### [0.1.0] - 2013-09-17
### Added
- Initial release of the reboot module


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
