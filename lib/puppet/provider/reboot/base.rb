require 'puppet/type'

Puppet::Type.type(:reboot).provide(:base) do
  def self.instances
    []
  end

  def when
    :absent
  end

  def when=(value)
  end

  def reboot
    Puppet::Application.stop!
  end
end
