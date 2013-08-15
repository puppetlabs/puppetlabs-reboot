Puppet::Type.newtype(:reboot) do
  newparam(:name) do
    isnamevar
  end

  newproperty(:when) do
    desc "When to check for, and if needed, perform a reboot. If `refreshed`
      then the reboot will only be performed, in response to a refresh
      event from another resource, e.g. `package`."
    newvalues(:refreshed)
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
    desc "Whether to prompt the user to continue the reboot. By default, the
      user will not be prompted."
    newvalues(:true, :false)
    defaultto(false)
  end

  newparam(:timeout) do
    desc "The amount of time to wait between the time the reboot is requested
      and when the reboot is initiated. The default timeout is 60 seconds."

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
