##2015-11-24 - Supported Release 1.2.1
###Summary

Add additional pending reboot scenario. Small bug fix.

###Features
* Pending reboot - Allow setting a flag directly on provider ([MODULES-2822](https://tickets.puppetlabs.com/browse/MODULES-2822))

###Bugfixes
* Fix use of read method from Registry ([MODULES-2804](https://tickets.puppetlabs.com/browse/MODULES-2804))

##2015-10-14 - Supported Release 1.2.0
###Summary

Detect more pending reboot scenarios.

###Features
* Pending reboot - detect computer rename ([MODULES-2657](https://tickets.puppetlabs.com/browse/MODULES-2657))
* Pending reboot - Detect DSC pending reboot state ([MODULES-2658](https://tickets.puppetlabs.com/browse/MODULES-2658))
* Pending reboot - Detect CCM pending reboot state ([MODULES-2659](https://tickets.puppetlabs.com/browse/MODULES-2659))

###Bugfixes
* Fix Linux provider failing ([MODULES-2585](https://tickets.puppetlabs.com/browse/MODULES-2585))

##2015-07-28 - Supported Release 1.1.0
###Summary

Deprecate Linux provider in favor of POSIX provider

###Features
* Move Linux provider to use new POSIX provider
* Unit and Acceptance Test case fixes
* Add notice when system is scheduling a reboot

##2015-04-15 - Supported Release 1.0.0
###Summary
This release adds support for rebooting Linux distributions in addition to Windows

###Features
* Add linux support
* Remove prompt for windows reboot
* Remove catalog_apply_timeout parameter
* Reboot is now triggered at_exit instead of watching for ruby process to end

##2014-11-11 - Supported Release 0.1.9
###Summary

Fixes issues URL in metadata

##2014-08-25 - Supported Release 0.1.8
###Summary

This release contains fixes for working on x64-native ruby.

##2014-07-15 - Supported Release 0.1.7
###Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

##2014-04-15, Supported Release 0.1.6
###Summary
This is a supported release.  No changes except metadata.

##2014-03-04, Supported Release 0.1.5
###Summary
This is a supported release.

####Known Bugs

* The version is `0.x` but should be considered a `1.x` for semantic versioning purposes.

---

###2014-02-07, Release 0.1.4

 * (PUP-1578) Workaround ruby bug that can prevent ruby.exe from exiting

###2013-09-27, Release 0.1.2

 * (PE-1669) Never load sample.pp in production

###2013-09-27, Release 0.1.1

 * (FM-105) Only manage reboot resources on systems where shutdown.exe exists
 * (FM-106) Module does not work on Windows 2003
 * (PP-433) Update description in init.pp

###2013-09-17, Release 0.1.0

Initial release of the reboot module
