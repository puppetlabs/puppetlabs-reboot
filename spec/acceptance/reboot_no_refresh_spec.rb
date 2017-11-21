require 'spec_helper_acceptance'

describe 'No Refresh' do

  let(:reboot_manifest) {
    <<-MANIFEST
      reboot { 'now':
      }
    MANIFEST
  }

  posix_agents.each do |agent|
    context "on #{agent}" do
      it 'Should not Reboot Computer without Refresh' do
        apply_manifest_on agent, reboot_manifest
        ensure_shutdown_not_scheduled(agent)
      end
    end
  end

  windows_agents.each do |agent|
    context "on #{agent}" do
      it 'Should not Reboot Computer without Refresh' do
        apply_manifest_on agent, reboot_manifest
        ensure_shutdown_not_scheduled(agent)
      end
    end
  end
end
