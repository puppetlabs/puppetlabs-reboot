class Watcher

  if File::ALT_SEPARATOR
    require 'windows/process'
    require 'windows/synchronize'
    require 'windows/handle'
    require 'windows/error'

    include Windows::Process
    include Windows::Synchronize
    include Windows::Handle
    include Windows::Error
  end

  attr_reader :pid, :timeout, :command

  def initialize(argv)
    @pid = argv[0].to_i
    @timeout = argv[1].to_i
    @command = argv[2]
  end

  def waitpid
    handle = OpenProcess(Windows::Process::SYNCHRONIZE, FALSE, pid)
    begin
      return WaitForSingleObject(handle, timeout * 1000)
    ensure
      CloseHandle(handle)
    end
  end

  def execute
    case waitpid
    when Windows::Synchronize::WAIT_OBJECT_0
      log_message("Process completed; executing '#{command}'.")
      system(command)
    when Windows::Synchronize::WAIT_TIMEOUT
      log_message("Timed out waiting for process to exit; reboot aborted.")
    else
      log_message("Failed to wait on the process (#{get_last_error}); reboot aborted.")
    end
  end

  def log_message(message)
    $stderr.puts(message)
  end
end

if __FILE__ == $0
  watcher = Watcher.new(ARGV)
  watcher.execute
end
