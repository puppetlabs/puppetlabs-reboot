require 'puppet/type'
require 'open3'

Puppet::Type.type(:reboot).provide :windows do
  confine :kernel => :windows
  defaultfor :kernel => :windows

  has_features :manages_reboot_pending, :supports_reboot_prompting

  def self.shutdown_command
    if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\shutdown.exe")
      "#{ENV['SYSTEMROOT']}\\sysnative\\shutdown.exe"
    elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\shutdown.exe")
      "#{ENV['SYSTEMROOT']}\\system32\\shutdown.exe"
    else
      'shutdown.exe'
    end
  end

  commands :shutdown => shutdown_command

  def self.instances
    []
  end

  def when
    case @resource[:when]
    when :pending
      reboot_pending? ? :absent : :pending
    else
      :absent
    end
  end

  def when=(value)
    if @resource[:when] == :pending
      reboot
    end
  end

  def cancel_transaction
    Puppet::Application.stop!
  end

  def reboot
    if @resource[:apply] == :finished && @resource[:when] == :pending
      Puppet.warning("The combination of `when => pending` and `apply => finished` is not a recommended or supported scenario. Please only use this scenario if you know exactly what you are doing. The puppet agent run will continue.")
    end

    if @resource[:apply] != :finished
      cancel_transaction
    end

    # for demo/testing
    interactive = @resource[:prompt] ? '/i' : nil

    shutdown_path = command(:shutdown)
    unless shutdown_path
      raise ArgumentError, "The shutdown.exe command was not found. On Windows 2003 x64 hotfix 942589 must be installed to access the 64-bit version of shutdown.exe from 32-bit version of ruby.exe."
    end

    # Reason code
    # E P     4       1       Application: Maintenance (Planned)
    shutdown_cmd = [shutdown_path, interactive, '/r', '/t', @resource[:timeout], '/d', 'p:4:1', '/c', "\"#{@resource[:message]}\""].join(' ')
    async_shutdown(shutdown_cmd)
  end

  def async_shutdown(shutdown_cmd)
    if Puppet[:debug]
      $stderr.puts(shutdown_cmd)
    end

    # execute a ruby process to shutdown after puppet exits
    watcher = File.join(File.dirname(__FILE__), 'windows', 'watcher.rb')
    if not File.exists?(watcher)
      raise ArgumentError, "The watcher program #{watcher} does not exist"
    end

    Puppet.debug("Launching 'ruby.exe #{watcher}'")
    pid = Process.spawn("ruby.exe '#{watcher}' #{Process.pid} #{@resource[:catalog_apply_timeout]} '#{shutdown_cmd}'")
    Puppet.debug("Launched process #{pid}")
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
