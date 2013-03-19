Puppet::Type.type(:reboot).provide(:windows) do
  confine :operatingsystem => :windows
  commands :shutdown => 'shutdown.exe'

  def reboot
    # don't evaluate any more resources
    Puppet::Application.stop!

    # for demo/testing
    interactive = @resource[:prompt] ? '/i' : nil

    # Reason code
    # E P     4       1       Application: Maintenance (Planned)
    shutdown(interactive, '/r', '/t', @resource[:when], '/d', 'p:4:1', '/c', "\"#{@resource[:message]}\"")
  end
end
