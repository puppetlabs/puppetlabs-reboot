module Puppet
  module Acceptance
    module Reboot

      require 'rubygems' # this is necessary for ruby 1.8
      require 'puppet/version'
      WINDOWS_SHUTDOWN_ABORT = 'cmd /c shutdown /a'
      #Some versions of ruby and puppet improperly report exit codes
      # due to a ruby bug the correct error code 1116, is returned modulo 256 = 92
      WINDOWS_SHUTDOWN_NOT_IN_PROGRESS = [1116, 1116 % 256]

      def shutdown_pid(agent)
        # code to get ps command taken from Facter 2.x implementation
        # as Facter 3.x is dropping the ps fact
        ps = case fact_on(agent, 'operatingsystem')
               when 'OpenWrt'
                 'ps www'
               when 'FreeBSD', 'NetBSD', 'OpenBSD', 'Darwin', 'DragonFly'
                 'ps auxwww'
               else
                 'ps -ef'
             end
        # code to isolate PID adapted from Puppet service base provider
        on(agent, ps).stdout.each_line { |line|
          if line.match(/shutdown/)
            return line.sub(/^\s+/, '').split(/\s+/)[1]
          end
        }
        nil
      end

      def ensure_shutdown_not_scheduled(agent)
        sleep 5

        if windows_agents.include?(agent)
          on agent, WINDOWS_SHUTDOWN_ABORT, {:acceptable_exit_codes => WINDOWS_SHUTDOWN_NOT_IN_PROGRESS}
        else
          pid = shutdown_pid(agent)
          if pid
            on(agent, "kill #{pid}", :acceptable_exit_codes => [0])
            raise CommandFailure, "Host '#{agent}' had unexpected scheduled shutdown with PID #{pid}."
          end
        end
      end

      def retry_shutdown_abort(agent, max_retries = 6)
        i = 0
        while i < max_retries
          if windows_agents.include?(agent)
            result = on(agent, WINDOWS_SHUTDOWN_ABORT, :acceptable_exit_codes => [0, WINDOWS_SHUTDOWN_NOT_IN_PROGRESS].flatten)
          else
            pid = shutdown_pid(agent)
            result = on(agent, "kill #{pid}", :acceptable_exit_codes => [0]) if pid
          end
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

      def posix_agents
        agents.select { |agent| !agent['platform'].include?('windows') }
      end

      def linux_agents
        agents.select { |agent| fact_on(agent, 'kernel') == 'Linux' }
      end
    end
  end
end
