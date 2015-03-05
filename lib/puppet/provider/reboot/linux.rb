Puppet::Type.type(:reboot).provide :linux do
  desc "Linux provider for the reboot type.

  This provider handles rebooting for Linux systems. It should be usable
  with minimal modification on other POSIX systems."

  confine :kernel => :linux
  defaultfor :kernel => :linux

  commands :shutdown => 'shutdown'

  def self.instances
    []
  end

  def when
    :absent
  end

  def when=(value)
  end

  def cancel_transaction
    Puppet::Application.stop!
  end

  def reboot
    if @resource[:apply] != :finished
      cancel_transaction
    end

    shutdown_path = command(:shutdown)
    unless shutdown_path
      raise ArgumentError, "The shutdown command was not found."
    end

    seconds = @resource[:timeout].to_i
    minutes = (seconds / 60.0).ceil
    if seconds % 60 != 0
      Puppet.warning("Shutdown command on this system specifies time in minutes, rounding #{seconds} seconds up to #{minutes} minutes.")
    end

    shutdown_cmd = [shutdown_path, '-r', "+#{minutes}", %Q("#{@resource[:message]}"), '</dev/null', '>/dev/null', '2>&1', '&'].join(' ')
    async_shutdown(shutdown_cmd)
  end

  def async_shutdown(shutdown_cmd)
    Puppet.debug("Adding #{shutdown_cmd} to ruby's at_exit handler")
    pid = Process.pid
    at_exit { system shutdown_cmd if Process.pid == pid }
  end
end
