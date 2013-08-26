require 'puppet/type'

Puppet::Type.type(:reboot).provide :windows, :parent => :base do
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows
  commands :shutdown => 'shutdown.exe'

  has_features :manages_reboot_pending

  def when
    case @resource[:when]
    when :pending
      reboot_pending? ? :absent : :pending
    else
      super
    end
  end

  def when=(value)
    case @resource[:when]
    when :pending
      reboot
    else
      super
    end
  end

  def reboot
    super

    # for demo/testing
    interactive = @resource[:prompt] ? '/i' : nil

    # Reason code
    # E P     4       1       Application: Maintenance (Planned)
    shutdown([interactive, '/r', '/t', @resource[:timeout], '/d', 'p:4:1', '/c', "\"#{@resource[:message]}\""])
  end

  def reboot_pending?
    # http://gallery.technet.microsoft.com/scriptcenter/Get-PendingReboot-Query-bdb79542

    component_based_servicing? ||
      windows_auto_update? ||
      pending_file_rename_operations? ||
      package_installer? ||
      package_installer_syswow64?
  end

  def vista_sp1_or_later?
    match = Facter[:kernelversion].value.match(/\d+\.\d+\.(\d+)/) and match[1].to_i >= 6001
  end

  def component_based_servicing?
    return false unless vista_sp1_or_later?

    # http://msdn.microsoft.com/en-us/library/windows/desktop/aa370556(v=vs.85).aspx
    path = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    pending = key_exists?(path)
    Puppet.debug("Pending reboot: HKLM\\#{path}") if pending
    pending
  end

  def windows_auto_update?
    path = 'SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    pending = key_exists?(path)
    Puppet.debug("Pending reboot: HKLM\\#{path}") if pending
    pending
  end

  def pending_file_rename_operations?
    pending = false

    path = 'SYSTEM\CurrentControlSet\Control\Session Manager'
    with_key(path) do |reg|
      renames = reg.read('PendingFileRenameOperations') rescue nil
      if renames
        pending = renames.length > 0
        if pending
          Puppet.debug("Pending reboot: HKLM\\PendingFileRenameOperations")
        end
      end
    end

    pending
  end

  def package_installer?
    # http://support.microsoft.com/kb/832475
    # 0x00000000 (0)	No pending restart.
    path = 'SOFTWARE\Microsoft\Updates'
    value = reg_value(path, 'UpdateExeVolatile')
    if value and value != 0
      Puppet.debug("Pending reboot: HKLM\\#{path}\\UpdateExeVolatile=#{value}")
      true
    else
      false
    end
  end

  def package_installer_syswow64?
    # http://support.microsoft.com/kb/832475
    # 0x00000000 (0)	No pending restart.
    path = 'SOFTWARE\Wow6432Node\Microsoft\Updates'
    value = reg_value(path, 'UpdateExeVolatile')
    if value and value != 0
      Puppet.debug("Pending reboot: HKLM\\#{path}\\UpdateExeVolatile=#{value}")
      true
    else
      false
    end
  end

  private

  def with_key(name, &block)
    require 'win32/registry'

    Win32::Registry::HKEY_LOCAL_MACHINE.open(name, Win32::Registry::KEY_READ | 0x100) do |reg|
      yield reg if block_given?
    end

    true
  rescue
    false
  end

  def reg_value(path, value)
    rval = nil

    with_key(path) do |reg|
      rval = reg.read(value)
    end

    rval
  end

  def key_exists?(path)
    with_key(path)
  end
end
