require 'spec_helper_acceptance'

describe 'Reboot Immediately and Explicit Immediately' do

  def apply_reboot_manifest(agent, reboot_manifest)
    apply_manifest_on agent, reboot_manifest
    retry_shutdown_abort(agent)
  end

  let(:reboot_manifest) {
    <<-MANIFEST
      notify { 'step_1':
      }
      ~>
      reboot { 'now':
      }
    MANIFEST
  }

  let(:reboot_immediate_manifest) {
    <<-MANIFEST
      notify { 'step_1':
      }
      ~>
      reboot { 'now':
        apply => immediately
      }
    MANIFEST
  }

  windows_agents.each do |agent|
    context "on #{agent}" do
      it 'Reboot Immediately with Refresh' do
        apply_reboot_manifest(agent, reboot_manifest)
      end
      it 'Reboot Immediately explicit with Refresh' do
        apply_reboot_manifest(agent, reboot_immediate_manifest)
      end
    end
  end

  posix_agents.each do |agent|
    context "on #{agent}" do
      it 'Reboot Immediately with Refresh' do
        apply_reboot_manifest(agent, reboot_manifest)
      end
      it 'Reboot Immediately explicit with Refresh' do
        apply_reboot_manifest(agent, reboot_immediate_manifest)
      end
    end
  end
end
