require 'spec_helper_acceptance'

describe 'Puppet Resume after Reboot' do
  def apply_reboot_manifest(reboot_manifest, pattern)
    apply_manifest(reboot_manifest, debug: true, catch_failures: true) do |result|
      # require 'pry'; binding.pry
      expect(result.stdout).to match(pattern)
    end
    expect(reboot_issued_or_cancelled).to be true
  end

  if os[:family] == 'windows'
    let(:reboot_manifest) do
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
    end
    let(:first_pattern) do
      %r{\[c:\/first.txt\]\/ensure: created}
    end
    let(:second_pattern) do
      %r{\[c:\/second.txt\]\/ensure: created}
    end
  else
    let(:reboot_manifest) do
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
    end
    let(:first_pattern) do
      %r{\[\/first.txt\]\/ensure: created}
    end
    let(:second_pattern) do
      %r{\[\/second.txt\]\/ensure: created}
    end
  end

  # Remove Test Artifacts
  after(:all) do
    remove_artifacts = <<-MANIFEST
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

    if os[:family] == 'windows'
      apply_manifest(windows_remove_artifacts, catch_failures: true)
    else
      apply_manifest(remove_artifacts, catch_failures: true)
    end
  end

  it 'Attempt First Reboot' do
    apply_reboot_manifest(reboot_manifest, first_pattern)
  end

  it 'Resume After Reboot' do
    apply_reboot_manifest(reboot_manifest, second_pattern)
  end

  it 'Verify Manifest is Finished' do
    apply_manifest(reboot_manifest)
    expect(reboot_issued_or_cancelled).to be(true)
  end
end
