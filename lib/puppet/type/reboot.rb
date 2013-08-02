Puppet::Type.newtype(:reboot) do
  newparam(:name) do
    isnamevar
  end

  newparam(:when) do
    newvalues(:refreshed)
    defaultto :refreshed
  end

  newparam(:message) do
    defaultto "Puppet is rebooting the computer"
  end

  newparam(:prompt, :boolean => true) do
    newvalues(:true, :false)
    defaultto(false)
  end

  def refresh
    case resource[:when]
    when :refreshed
      provider.reboot
    else
      Puppet.debug("Skipping reboot")
    end
  end
end
