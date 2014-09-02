module Puppet
  module Acceptance
    module Reboot
      # due to a ruby bug the correct error code 1116, is returned modulo 256 = 92
      SHUTDOWN_ABORT = 'cmd /c shutdown /a'
      SHUTDOWN_NOT_IN_PROGRESS = 1116 % 256

      def ensure_shutdown_not_scheduled(agent)
        sleep 5

        on(agent, SHUTDOWN_ABORT, :acceptable_exit_codes => [SHUTDOWN_NOT_IN_PROGRESS])
      end

      def retry_shutdown_abort(agent, max_retries = 6)
        i = 0
        while i < max_retries
          result = on(agent, SHUTDOWN_ABORT, :acceptable_exit_codes => [0, SHUTDOWN_NOT_IN_PROGRESS])
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
    end
  end
end
