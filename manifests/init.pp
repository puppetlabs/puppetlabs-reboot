# == Class: reboot
#
# This module provides a type and provider for managing systems reboots.
# Currently, only Windows is supported.
#
# The module supports two forms of reboots. The first form occurs when
# puppet installs a package, and a reboot is required to complete
# installation. This is the default mode of operation, as it ensures
# puppet will only reboot the system in response to another resource being
# applied, such as a package install.
#
# The second form is where a reboot is pending, and puppet needs to
# reboot the system before applying any other resources. For example,
# some Windows packages cannot be installed while a reboot is pending.
# The second form is specified via when => pending.
#
# === Parameters
#
# [*name*]
#   The name of the reboot resource. Used for uniqueness.
#
# [*apply*]
#   When to apply the reboot. If immediately, then the provider will
#   stop applying additional resources and apply the reboot once puppet
#   has finished syncing. If finished, it will continue applying
#   resources and then perform a reboot at the end of the run. The
#   default is immediately. Valid values are immediately, finished.
#
# [*message*]
#   The message to log when the reboot is performed.
#
# [*prompt*]
#   Whether to prompt the user to continue the reboot. By default, the
#   user will not be prompted. Valid values are true, false. Should only
#   be used with `puppet apply`, not puppet agent runs.
#
# [*catalog_apply_timeout*]
#   The maximum amount of time in seconds to wait for puppet to finish
#   applying the catalog. If puppet is still running when the timeout is
#   reached, the reboot will not be requested. The default value is
#   7200 seconds (2 hours).
#
# [*timeout*]
#   The amount of time in seconds to wait between the time the reboot is
#   requested and when the reboot is performed. The default timeout is
#   60 seconds. Note that this time starts once puppet has exited the
#   current run.
#
# === Properties
#
# [*when*]
#   When to check for, and if needed, perform a reboot. If pending,
#   then the provider will check if a reboot is pending, and only if
#   needed, reboot the system. If refreshed then the reboot will only
#   be performed in response to a refresh event from another resource,
#   e.g. package. Valid values are refreshed, pending.
#
# === Variables
#
#
# === Examples
#
# To install .NET 4.5 and reboot, but only if the package needed to be
# installed:
#
#    package { 'Microsoft .NET Framework 4.5':
#      ensure          => installed,
#      source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
#      install_options => ['/Passive', '/NoRestart'],
#      provider        => windows,
#    }
#    reboot { 'after':
#      subscribe       => Package['Microsoft .NET Framework 4.5'],
#    }
#
# To check if a reboot is pending, and if so, reboot the system before
# installing .NET 4.5:
#
#    reboot { 'before':
#      when            => pending,
#    }
#    package { 'Microsoft .NET Framework 4.5':
#      ensure          => installed,
#      source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
#      install_options => ['/Passive', '/NoRestart'],
#      provider        => windows,
#      require         => Reboot['before'],
#    }
#
# By default, when the provider triggers a reboot, it will skip any
# resources in the catalog that have not yet been applied. Alternatively,
# you can allow puppet to continue applying the entire catalog by
# specifying apply => finished. For example, if you have several
# packages that all require reboots, but will not block each other:
#
#    package { 'Microsoft .NET Framework 4.5':
#      ensure => installed,
#      ...
#      notify => Reboot['after_run'],
#    }
#    package { 'Microsoft Windows SDK for Windows 7 (7.0)':
#      ensure => installed,
#      ...
#      notify => Reboot['after_run'],
#    }
#    reboot { 'after_run':
#      apply  => finished,
#    }
#
# === Authors
#
# Josh Cooper <josh@puppetlabs.com>
# Rob Reynolds <rob@puppetlabs.com>
# Ethan Brown <ethan@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013 Puppet Labs, unless otherwise noted.
#
class reboot {


}
