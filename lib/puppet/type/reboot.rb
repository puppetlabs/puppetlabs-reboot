Puppet::Type.newtype(:reboot) do
  @doc = <<-'EOT'
    Manages system reboots.  The `reboot` type is typically
    used in situations where a resource performs a change, e.g.
    package install, and a reboot is required to complete
    installation.  Only if the package is installed should the
    reboot be triggered.

    Sample usage:

      package { 'IIS':
        source => '\\server\share\iis.exe'
      }
      reboot { 'now':
        subscribe => Package['IIS']
      }

    A reboot resource can also check if the system is in a
    reboot pending state, and if so, reboot the system.  For
    example, if you have a package that cannot be installed
    while a reboot is pending.

    Sample usage:

      reboot { 'now':
        when   => pending,
        before => Package['IIS']
      }
      package { 'IIS':
        source => '\\server\share\iis.exe'
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

  newparam(:message) do
    desc "The message to log when the reboot is performed."

    validate do |value|
      if value.nil? or value == ""
        raise ArgumentError, "A non-empty message must be specified."
      end
    end

    defaultto "Puppet is rebooting the computer"
  end

  newparam(:prompt, :boolean => true) do
    desc "Whether to prompt the user to continue the reboot.  By default, the
      user will not be prompted."
    newvalues(:true, :false)
    defaultto(false)
  end

  newparam(:timeout) do
    desc "The amount of time to wait between the time the reboot is requested
      and when the reboot is initiated.  The default timeout is 60 seconds."

    validate do |value|
      begin
        value = Integer(value)
      rescue ArgumentError
        raise ArgumentError, "The timeout must be an integer."
      end
    end

    defaultto 60
  end

  def refresh
    case self[:when]
    when :refreshed
      provider.reboot
    else
      Puppet.debug("Skipping reboot")
    end
  end
end
