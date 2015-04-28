# reboot
[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-reboot.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-reboot)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the reboot module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with reboot](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with reboot](#beginning-with-reboot)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Development - Guide for contributing to the module](#development)

##Overview

This module adds a type, and both Windows and generic POSIX providers, for managing node reboots.

##Module Description

Some packages require a reboot of the node to complete their installation. Until that reboot is completed, the package might not be fully functional, and other installs might fail. This module provides a resource type to let Puppet perform that reboot, and providers to support Windows and POSIX systems. HP-UX is not supported.

By default, this module only reboots a node in response to another resource being applied --- e.g., after a package install. On Windows nodes, you can also have Puppet check for pending reboots and complete them *before* applying the next resource in the catalog, by specifying `when => pending`.

##Setup

###Setup Requirements

On Windows nodes, the 'shutdown.exe' command must be in the `PATH`.

On Windows 2003 (non-R2) x64 nodes, [KB942589](http://support.microsoft.com/kb/942589) must be installed.

###Beginning with reboot

The reboot module should work right out of the box. To test it, install a package (in this case 'SomePackage') and set up the module to reboot as follows:

    package { 'SomeModule':
      ensure          => installed,
      source          => '\\server\share\some_installer.exe',
      install_options => ['/Passive', '/NoRestart'],
    }
    reboot { 'after':
      subscribe       => Package['SomePackage'],
    }

##Usage

###Complete any pending reboots before installing a package

    reboot { 'before':
      when            => pending,
    }
    package { 'SomePackage':
      ensure          => installed,
      source          => '\\server\share\some_installer.exe',
      install_options => ['/Passive', '/NoRestart'],
      require         => Reboot['before'],
    }

###Install multiple packages before rebooting

By default, when this module triggers a reboot, it skips any resources in the catalog that have not yet been applied. To apply the entire catalog before rebooting, specify `apply => finished`. For example, if you have several packages that all require reboots, but will not block each other:

    package { 'Microsoft .NET Framework 4.5':
      ensure => installed,
      ...
      notify => Reboot['after_run'],
    }
    package { 'Microsoft Windows SDK for Windows 7 (7.0)':
      ensure => installed,
      ...
      notify => Reboot['after_run'],
    }
    reboot { 'after_run':
      apply  => finished,
    }

##Reference

###Type: reboot

The main type of the module, responsible for all its functionality.

####Providers

* `windows`: Default for :kernel => :windows
* `linux`: Deprecated. Use `posix` instead.
* `posix`: Default for :feature => :posix

####Features

* `manages_reboot_pending`: Detects whether a reboot is pending due to a prior change. If so, reboot the node. (Available with the `windows` provider.)

####Parameters

#####`apply`

*Optional.* Specifies when to apply the reboot. If set to 'immediately', the provider stops applying additional resources and performs the reboot as soon as Puppet finishes syncing. If set to 'finished', it continues applying resources and then performs the reboot at the end of the run. Valid options: 'immediately' and 'finished'. Default value: 'immediately'.

**Note:** With the default setting of 'immediately', resources further down in the catalog are skipped and recorded as such. (In Puppet versions prior to 3.3.0, they're left out of the report entirely.) The next time Puppet runs, it processes the skipped resources normally, and they might trigger additional reboots.

#####`message`

*Optional.* Provides a message to log when the reboot is performed. Valid options: a string. Default value: undefined.

#####`name`

*Required.* Sets the name of the reboot resource. Valid options: a string.

#####`timeout`

*Optional.* Sets the number of seconds to wait after the Puppet run completes for the reboot to happen. If the timeout is exceeded, the provider cancels the reboot. Valid options: any positive integer. Default value: '60'.

**Note:** POSIX systems (with the exception of Solaris) only support specifying the timeout as minutes. As such, the value of `timeout` must be a multiple of 60. Other values will be rounded up to the nearest minute and a warning will be issued.

#####`when`

*Optional.* Specifies how reboots are triggered. If set to 'refreshed', the provider only reboots the node in response to a refresh event from another resource, e.g., installing a package. If set to 'pending', Puppet checks for signs of any pending reboots and completes them before applying the next resource in the catalog. Valid options: 'refreshed' and 'pending'. Default value: 'refreshed'.

**Note:** For `when => pending` reboots, Puppet can normally detect a pending reboot based on some specific system conditions (such as the existence of the PendingFileRenameOperations registry key). However, if those conditions aren't resolved after the node reboots, Puppet triggers another reboot. This can lead to a reboot loop.

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

###Contributors

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-reboot/graphs/contributors)
