require 'spec_helper_acceptance'

describe 'Custom Timeout' do
  let(:reboot_manifest) do
    <<-MANIFEST
      notify { 'step_1':
      }
      ~>
      reboot { 'now':
        when => refreshed,
        timeout => 120,
      }
    MANIFEST
  end

  posix_agents.each do |agent|
    context "on #{agent}" do
      it 'Reboot Immediately with a Custom Timeout' do
        execute_manifest_on(agent, reboot_manifest, debug: true) do |result|
          expected_command = if fact_on(agent, 'kernel') == 'SunOS'
                               %r{shutdown -y -i 6 -g 120}
                             else
                               %r{shutdown -r \+2}
                             end

          assert_match expected_command,
                       result.stdout, 'Expected reboot timeout is incorrect'
        end
        sleep 61
        retry_shutdown_abort(agent)
      end
    end
  end

  windows_agents.each do |agent|
    context "on #{agent}" do
      it 'Reboot Immediately with a Custom Timeout' do
        execute_manifest_on(agent, reboot_manifest, debug: true) do |result|
          assert_match %r{shutdown\.exe \/r \/t 120 \/d p:4:1},
                       result.stdout, 'Expected reboot timeout is incorrect'
        end
        sleep 61
        retry_shutdown_abort(agent)
      end
    end
  end
end
