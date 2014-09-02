class Watcher
  require 'tempfile'

  module Win32
    if File::ALT_SEPARATOR
      require 'ffi'

      extend FFI::Library

      ffi_convention :stdcall

      typedef :uint32, :dword
      # uintptr_t is defined in an FFI conf as platform specific, either
      # ulong_long on x64 or just ulong on x86
      typedef :uintptr_t, :handle
      # FFI bool can be only 1 byte at times,
      # Win32 BOOL is a signed int, and is always 4 bytes, even on x64
      # http://blogs.msdn.com/b/oldnewthing/archive/2011/03/28/10146459.aspx
      typedef :int32, :win32_bool

      # http://msdn.microsoft.com/en-us/library/windows/desktop/ms684320(v=vs.85).aspx
      # HANDLE WINAPI OpenProcess(
      #   _In_  DWORD dwDesiredAccess,
      #   _In_  BOOL bInheritHandle,
      #   _In_  DWORD dwProcessId
      # );
      ffi_lib :kernel32
      attach_function :OpenProcess,
        [:dword, :win32_bool, :dword], :handle

      # http://msdn.microsoft.com/en-us/library/windows/desktop/ms724211(v=vs.85).aspx
      # BOOL WINAPI CloseHandle(
      #   _In_  HANDLE hObject
      # );
      ffi_lib :kernel32
      attach_function :CloseHandle, [:handle], :win32_bool

      # http://msdn.microsoft.com/en-us/library/windows/desktop/ms687032(v=vs.85).aspx
      # DWORD WINAPI WaitForSingleObject(
      #   _In_  HANDLE hHandle,
      #   _In_  DWORD dwMilliseconds
      # );
      ffi_lib :kernel32
      attach_function :WaitForSingleObject,
        [:handle, :dword], :dword
    end

  end

  attr_reader :pid, :timeout, :command

  def initialize(argv)
    @pid = argv[0].to_i
    @timeout = argv[1].to_i
    @command = argv[2]

    # this should go to eventlog
    @path = Tempfile.new('puppet-reboot-watcher').path
    File.open(@path, 'w') {|fh| }
  end

  NULL_HANDLE               = 0
  FALSE                     = 0
  WAIT_OBJECT_0             = 0
  WAIT_FAILED               = 0xFFFFFFFF
  WAIT_TIMEOUT              = 0x00000102
  SYNCHRONIZE               = 1048576
  ERROR_INVALID_PARAMETER   = 0x57

  def waitpid
    begin
      handle = Win32::OpenProcess(SYNCHRONIZE, FALSE, pid)
      if handle == NULL_HANDLE
        if FFI.errno == ERROR_INVALID_PARAMETER
          log_message("Process #{pid} already exited")
          wait_status = WAIT_OBJECT_0
        else
          wait_status = WAIT_FAILED
        end
      else
        wait_status = Win32::WaitForSingleObject(handle, timeout * 1000)
      end
    ensure
      Win32::CloseHandle(handle) if handle
    end

    wait_status
  end

  def execute
    case waitpid
    when WAIT_OBJECT_0
      log_message("Process completed; executing '#{command}'.")
      system(command)
    when WAIT_TIMEOUT
      log_message("Timed out waiting for process to exit; reboot aborted.")
    else
      log_message("Failed to wait on the process (#{get_last_error}); reboot aborted.")
    end
  end

  def log_message(message)
    File.open(@path, 'a') { |fh| fh.puts(message) }
  end
end

if __FILE__ == $0
  watcher = Watcher.new(ARGV)
  begin
    watcher.execute
  rescue Exception => e
    watcher.log_message(e.message)
    watcher.log_message(e.backtrace)
  end
end
