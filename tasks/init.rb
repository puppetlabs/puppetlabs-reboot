require 'facter'
require 'json'

params   = JSON.parse(STDIN.read)
timeout  = params['timeout'].to_i || 3
message  = params['message']

def async_command(cmd)
  wait_time = 3
  case Facter.value(:kernel)
  when 'windows'
    # This appears to be the only way to get the processes to properly detach
    # themselves, it was a HUGE PAIN to fugure out
    require 'win32/process'
    Process.create(command_line: "cmd /c start #{cmd}",
                   creation_flags: Process::DETACHED_PROCESS)
  else
    # Fork the process so that we can have one return the status and one
    # actually do the work
    if fork.nil?
      # Detatch itself completely
      Process.daemon
      # Wait the prescribed amount of time
      sleep wait_time
      # Replace itself with the reboot command
      exec(*cmd)
    end
  end
end

def shutdown_executable_windows
  if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\shutdown.exe")
    "#{ENV['SYSTEMROOT']}\\sysnative\\shutdown.exe"
  elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\shutdown.exe")
    "#{ENV['SYSTEMROOT']}\\system32\\shutdown.exe"
  else
    'shutdown.exe'
  end
end

def windows_shutdown_command(params)
  params[:timeout] = 3 if params[:timeout] < 3
  message_params = ['/c', "\"#{params[:message]}\""] if params[:message]
  [shutdown_executable_windows, '/r', '/t', params[:timeout], '/d', 'p:4:1', message_params].join(' ')
end

def unix_shutdown_command(params)
  require 'shellwords'
  escaped_message = Shellwords.escape(params[:message])
  flags = if Facter.value(:kernel) == 'SunOS'
            ['-y', '-i', '6', '-g', params[:timeout], escaped_message]
          else
            ['-r', "+#{params[:timeout]}", escaped_message]
          end
  ['shutdown', flags, '</dev/null', '>/dev/null', '2>&1', '&'].flatten
end

# Actually shut down the computer
if Facter.value(:kernel) == 'windows'
  async_command(windows_shutdown_command(timeout: timeout, message: message))
else
  # Round to minutes for everything but SunOS
  if Facter.value(:kernel) == 'SunOS'
    timeout_os = timeout
  else
    timeout_os = (timeout / 60.0).ceil
    timeout = timeout_os * 60
  end
  async_command(unix_shutdown_command(timeout: timeout_os, message: message))
end

result = {
  'status' => 'queued',
  'timeout' => timeout,
}
JSON.dump(result, STDOUT)
