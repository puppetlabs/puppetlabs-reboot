Puppet::Type.newtype(:reboot) do
  newparam(:name) do
    isnamevar
  end

  newparam(:when) do
    munge do |value|
      30 # seconds
    end
    newvalues(:now)
  end

  newparam(:message) do
    defaultto "Puppet is rebooting the computer"
  end

  newparam(:prompt, :boolean => true) do
    newvalues(:true, :false)
    defaultto(false)
  end

  def refresh
    provider.reboot
  end
end
