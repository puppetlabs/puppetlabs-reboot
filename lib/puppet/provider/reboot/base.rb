require 'puppet/type'

Puppet::Type.type(:reboot).provide(:base) do
  def reboot
    Puppet::Application.stop!
  end
end
