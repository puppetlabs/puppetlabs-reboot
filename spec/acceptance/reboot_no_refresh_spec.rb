require 'spec_helper_acceptance'

describe 'No Refresh' do
  let(:reboot_manifest) do
    <<-MANIFEST
      reboot { 'now':
      }
    MANIFEST
  end

  posix_agents.each do |agent|
    context "on #{agent}" do
      it 'does not Reboot Computer without Refresh' do
        execute_manifest_on(agent, reboot_manifest)
        ensure_shutdown_not_scheduled(agent)
      end
    end
  end

  windows_agents.each do |agent|
    context "on #{agent}" do
      it 'does not Reboot Computer without Refresh' do
        execute_manifest_on(agent, reboot_manifest)
        ensure_shutdown_not_scheduled(agent)
      end
    end
  end
end
