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

  def apply
    :absent
  end

  def apply=(value)
  end

  def cancel_transaction
    Puppet::Application.stop!
  end
end
