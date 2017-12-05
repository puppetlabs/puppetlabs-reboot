require 'spec_helper_acceptance'

describe 'Puppet Resume after Reboot' do

  def apply_reboot_manifest(agent, reboot_manifest, match)
    apply_manifest_on(agent, reboot_manifest) do |result|
      assert_match match, result.stdout, 'Expected file was not created'
    end
    retry_shutdown_abort(agent)
  end

  let(:reboot_manifest) {
    <<-MANIFEST
      file { '/first.txt':
        ensure => file,
      } ~>
      reboot { 'first_reboot':
      } ->
      file { '/second.txt':
        ensure => file,
      } ~>
      reboot { 'second_reboot':
      }
    MANIFEST
  }

  let(:windows_reboot_manifest) {
    <<-MANIFEST
      file { 'c:/first.txt':
        ensure => file,
      } ~>
      reboot { 'first_reboot':
      } ->
      file { 'c:/second.txt':
        ensure => file,
      } ~>
      reboot { 'second_reboot':
      }
    MANIFEST
  }

  # Remove Test Artifacts
  after(:all) do
    remove_artifacts =  <<-MANIFEST
      file { '/first.txt':
        ensure => absent,
      }
      file { '/second.txt':
        ensure => absent,
      }
      MANIFEST

    windows_remove_artifacts = <<-MANIFEST
      file { 'c:/first.txt':
        ensure => absent,
      }
      file { 'c:/second.txt':
        ensure => absent,
      }
      MANIFEST

    posix_agents.each { |agent|
      apply_manifest_on agent, remove_artifacts
    }
    windows_agents.each { |agent|
      apply_manifest_on agent, windows_remove_artifacts
    }
  end

  posix_agents.each do |agent|
    context "on #{agent}" do
      it 'Attempt First Reboot' do
        apply_reboot_manifest(agent, reboot_manifest, /\[\/first.txt\]\/ensure: created/)
      end

      it 'Resume After Reboot' do
        apply_reboot_manifest(agent, reboot_manifest, /\[\/second.txt\]\/ensure: created/)
      end

      it 'Verify Manifest is Finished' do
        apply_manifest_on agent, reboot_manifest
        ensure_shutdown_not_scheduled(agent)
      end
    end
  end

  windows_agents.each do |agent|
    context "on #{agent}" do
      it 'Attempt First Reboot' do
        apply_reboot_manifest(agent, windows_reboot_manifest, /\[c:\/first.txt\]\/ensure: created/)
      end

      it 'Resume After Reboot' do
        apply_reboot_manifest(agent, windows_reboot_manifest, /\[c:\/second.txt\]\/ensure: created/)
      end

      it 'Verify Manifest is Finished' do
        apply_manifest_on agent, windows_reboot_manifest
        ensure_shutdown_not_scheduled(agent)
      end
    end
  end
end
