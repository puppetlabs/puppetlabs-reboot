require 'puppet/type'

Puppet::Type.type(:reboot).provide :windows, :parent => :base do
  confine :operatingsystem => :windows
  commands :shutdown => 'shutdown.exe'

  def reboot
    super

    # for demo/testing
    interactive = @resource[:prompt] ? '/i' : nil

    # Reason code
    # E P     4       1       Application: Maintenance (Planned)
    shutdown(interactive, '/r', '/t', @resource[:when], '/d', 'p:4:1', '/c', "\"#{@resource[:message]}\"")
  end
end
