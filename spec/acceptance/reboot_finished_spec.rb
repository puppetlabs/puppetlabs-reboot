require 'spec_helper_acceptance'

describe 'Reboot when Finished' do
  def apply_reboot_manifest(agent, reboot_manifest)
    execute_manifest_on(agent, reboot_manifest) do |result|
      assert_match %r{defined 'message' as 'step_2'},
                   result.stdout, 'Expected step was not finished before reboot'
    end
    retry_shutdown_abort(agent)
  end

  let(:reboot_manifest) do
    <<-MANIFEST
      notify { 'step_1':
      } ~>
      reboot { 'now':
        apply => finished
      } ->
      notify { 'step_2':
      }
    MANIFEST
  end

  windows_agents.each do |agent|
    context "on #{agent}" do
      it 'Reboot After Finishing Complete Catalog' do
        apply_reboot_manifest(agent, reboot_manifest)
      end
    end
  end

  posix_agents.each do |agent|
    context "on #{agent}" do
      it 'Reboot After Finishing Complete Catalog' do
        apply_reboot_manifest(agent, reboot_manifest)
      end
    end
  end
end
