Puppet::Type.newtype(:reboot) do
  @doc = <<-'EOT'
    Manages system reboots.  The `reboot` type is typically
    used in situations where a resource performs a change, e.g.
    package install, and a reboot is required to complete
    installation.  Only if the package is installed should the
    reboot be triggered.

    Sample usage:

        package { 'Microsoft .NET Framework 4.5':
          ensure          => installed,
          source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
          install_options => ['/Passive', '/NoRestart'],
          provider        => windows,
        }
        reboot { 'after':
          subscribe       => Package['Microsoft .NET Framework 4.5'],
        }

    A reboot resource can also check if the system is in a
    reboot pending state, and if so, reboot the system.  For
    example, if you have a package that cannot be installed
    while a reboot is pending.

    Sample usage:

        reboot { 'before':
          when            => pending,
        }
        package { 'Microsoft .NET Framework 4.5':
          ensure          => installed,
          source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
          install_options => ['/Passive', '/NoRestart'],
          provider        => windows,
          require         => Reboot['before'],
        }

    A reboot resource can also finish the run and then reboot the system.  For
    example, if you have a few packages that all require reboots but will not block
    each other during the run.

    Sample usage:

        package { 'Microsoft .NET Framework 4.5':
          ensure          => installed,
          source          => '\\server\share\dotnetfx45_full_x86_x64.exe',
          install_options => ['/Passive', '/NoRestart'],
          provider        => windows,
        }
        reboot { 'after_run':
          apply           => finished,
          subscribe       => Package['Microsoft .NET Framework 4.5'],
        }
  EOT

  feature :manages_reboot_pending, "The provider can detect if a reboot is pending, and reboot as needed."

  newparam(:name) do
    desc "The name of the reboot resource.  Used for uniqueness."
    isnamevar
  end

  newproperty(:when) do
    desc "When to check for, and if needed, perform a reboot. If `pending`,
      then the provider will check if a reboot is pending, and only
      if needed, reboot the system.  If `refreshed` then the reboot
      will only be performed in response to a refresh event from
      another resource, e.g. `package`."
    newvalue(:refreshed)
    newvalue(:pending, :required_features => :manages_reboot_pending)
    defaultto :refreshed

    def insync?(is)
      case should
      when :refreshed
        true # we're always insync
      else
        super
      end
    end
  end

  newparam(:apply) do
    desc "When to apply the reboot. If `immediately`, then the provider
      will stop applying additional resources and apply the reboot once
      puppet has finished syncing. If `finished`, it will continue
      applying resources and then perform a reboot at the end of the
      run. The default is `immediately`."
    newvalues(:immediately, :finished)
    defaultto :immediately
  end

  newparam(:message) do
    desc "The message to log when the reboot is performed."

    validate do |value|
      if value.nil? or value == ""
        raise ArgumentError, "A non-empty message must be specified."
      end

      # Maximum command line length in Windows is 8191 characters, so this is
      # an approximation based on the other parts of the shutdown command
      if value.length > 8000
        raise ArgumentError, "The given message must not exceed 8000 characters."
      end
    end

    defaultto "Puppet is rebooting the computer"
  end

  newparam(:timeout) do
    desc "The amount of time in seconds to wait between the time the reboot
      is requested and when the reboot is performed.  The default timeout
      is 60 seconds.  Note that this time starts once puppet has exited the
      current run."

    validate do |value|
      if value.to_s !~ /^\d+$/
        raise ArgumentError, "The timeout must be an integer."
      end
    end

    defaultto 60
  end

  @rebooting = false

  def self.rebooting
    @rebooting
  end

  def self.rebooting=(value)
    @rebooting = value
  end

  def refresh
    case self[:when]
    when :refreshed
      if self.class.rebooting
        Puppet.debug("Reboot already scheduled; skipping")
      else
        self.class.rebooting = true
        Puppet.notice("Scheduling system reboot with message: \"#{self[:message]}\"")
        provider.reboot
      end
    else
      Puppet.debug("Skipping reboot")
    end
  end
end
