# reboot

##Overview

This module adds a type and both Windows and generic Linux providers for managing system reboots.

##Module Description

This module provides a type and providers for managing systems reboots. Windows and Linux are supported.

The module supports two forms of reboots. The first form occurs when puppet installs a package, and a reboot is required to complete installation. This is the default mode of operation, as it ensures puppet will only reboot the system in response to another resource being applied, such as a package install.

The second form is where a reboot is pending, and puppet needs to reboot the system before applying any other resources. For example, some Windows packages cannot be installed while a reboot is pending. The second form is specified via `when => pending`. Note that this is only supported for providers that offer the `manages_reboot_pending` feature. Currently, only the Windows provider offers this.

##Setup

###Beginning with reboot

The best way to install this module is with the `puppet module` subcommand.  On your puppet master, execute the following command, optionally specifying your puppet master's `modulepath` in which to install the module:

    $ puppet module install [--modulepath <path>] puppetlabs/reboot

See the section [Installing Modules](http://docs.puppetlabs.com/puppet/2.7/reference/modules_installing.html) for more information.

##Usage

To install .NET 4.5 and reboot, but only if the package needed to be installed:

    package { 'Microsoft .NET Framework 4.5':
      ensure          => installed,
      source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
      install_options => ['/Passive', '/NoRestart'],
    }
    reboot { 'after':
      subscribe       => Package['Microsoft .NET Framework 4.5'],
    }

To check if a reboot is pending, and if so, reboot the system before installing .NET 4.5:

    reboot { 'before':
      when            => pending,
    }
    package { 'Microsoft .NET Framework 4.5':
      ensure          => installed,
      source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
      install_options => ['/Passive', '/NoRestart'],
      require         => Reboot['before'],
    }

By default, when the provider triggers a reboot, it will skip any resources in the catalog that have not yet been applied. Alternatively, you can allow puppet to continue applying the entire catalog by specifying `apply => finished`. For example, if you have several packages that all require reboots, but will not block each other:

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

##Limitations

 * On Windows, the 'shutdown.exe' command must be in the `PATH`.
 * On Windows 2003 (non-R2) x64, [KB942589](http://support.microsoft.com/kb/942589) must be installed.
 * If using `when => pending` style reboots, puppet will apply heuristics to determine if a reboot is pending, e.g. the existence of the PendingFileRenameOperations registry key. If the system reboots, but does not resolve the reboot pending condition, then puppet will reboot the system again. This could lead to a reboot cycle.
 * If puppet performs a reboot, any remaining items in the catalog will be applied the next time puppet runs. In other words, it may take more than one run to reach consistency. In situations where puppet is running as a service, puppet should execute again after the machine boots.
 * In puppet 3.3.0 and up, if puppet performs a reboot, any resource in the catalog that is skipped will be marked as such in the report. In versions prior, skipped resources are omitted from the report.
 * The `prompt` parameter should only be used with `puppet apply`. The prompt isn't displayed during puppet agent runs, which causes the operation to wait indefinitely.
 * The `prompt` parameter is only supported with providers that offer the `supports_reboot_prompting` feature. Currently, only the Windows provider offers this.

##License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
