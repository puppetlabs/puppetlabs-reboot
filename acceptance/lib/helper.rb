module Puppet
  module Acceptance
    module Reboot
      # due to a ruby bug the correct error code 1116, is returned modulo 256 = 92
      # Puppet 3.4.0+ work around this issue
      require 'rubygems' # this is necessary for ruby 1.8
      require 'puppet/version'
      WINDOWS_SHUTDOWN_ABORT = 'cmd /c shutdown /a'
      if Gem::Version.new(Puppet.version) < Gem::Version.new('3.4.0')
        WINDOWS_SHUTDOWN_NOT_IN_PROGRESS = 1116 % 256
      else
        WINDOWS_SHUTDOWN_NOT_IN_PROGRESS = 1116
      end

      LINUX_SHUTDOWN_ABORT = 'shutdown -c'
      LINUX_SHUTDOWN_NOT_IN_PROGRESS = 1

      def ensure_shutdown_not_scheduled(agent)
        sleep 5

        if windows_agents.include?(agent)
          on(agent, WINDOWS_SHUTDOWN_ABORT, :acceptable_exit_codes => [WINDOWS_SHUTDOWN_NOT_IN_PROGRESS])
        else
          on(agent, LINUX_SHUTDOWN_ABORT, :acceptable_exit_codes => [LINUX_SHUTDOWN_NOT_IN_PROGRESS])
        end
      end

      def retry_shutdown_abort(agent, max_retries = 6)
        i = 0
        abort_cmd = windows_agents.include?(agent) ? WINDOWS_SHUTDOWN_ABORT : LINUX_SHUTDOWN_ABORT
        not_in_progress = windows_agents.include?(agent) ? WINDOWS_SHUTDOWN_NOT_IN_PROGRESS : LINUX_SHUTDOWN_NOT_IN_PROGRESS
        while i < max_retries
          result = on(agent, abort_cmd, :acceptable_exit_codes => [0, not_in_progress])
          break if result.exit_code == 0

          Beaker::Log.warn("Reboot is not yet scheduled; sleeping for #{1 << i} seconds")
          sleep 1 << i
          i += 1
        end

        if i == max_retries
          fail_test "Failed to abort shutdown on #{agent}"
        end
      end

      def windows_agents
        agents.select { |agent| agent['platform'].include?('windows') }
      end

      def linux_agents
        agents.select { |agent| agent['platform'] =~ /centos|fedora|ubuntu|debian|sles/ }
      end
    end
  end
end
