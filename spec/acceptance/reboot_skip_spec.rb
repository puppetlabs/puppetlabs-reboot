require 'spec_helper_acceptance'

describe 'Reboot Skip' do
  def apply_reboot_manifest(reboot_manifest)
    apply_manifest(reboot_manifest, debug: true, catch_failures: true) do |result|
      expect(result.stdout).to match(%r{Transaction canceled, skipping})
    end
    expect(reboot_issued_or_cancelled).to be(true)
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

  it 'Reboot Immediately with Skipping Other Resources' do
    apply_reboot_manifest(reboot_manifest)
  end
end
