require 'spec_helper_acceptance'

describe 'Reboot Skip' do
  def apply_reboot_manifest(agent, reboot_manifest)
    execute_manifest_on(agent, reboot_manifest, debug: true) do |result|
      assert_match %r{Transaction canceled, skipping},
                   result.stdout, 'Expected resource was not skipped'
    end
    retry_shutdown_abort(agent)
  end

  let(:reboot_manifest) do
    <<-MANIFEST
      notify { 'step_1':
      } ~>
      reboot { 'now':
      } ->
      notify { 'step_2':
      }
    MANIFEST
  end

  posix_agents.each do |agent|
    context "on #{agent}" do
      it 'Reboot Immediately with Skipping Other Resources' do
        apply_reboot_manifest(agent, reboot_manifest)
      end
    end
  end

  windows_agents.each do |agent|
    context "on #{agent}" do
      it 'Reboot Immediately with Skipping Other Resources' do
        apply_reboot_manifest(agent, reboot_manifest)
      end
    end
  end
end
