require 'spec_helper_acceptance'

describe 'Custom Message' do
  let(:reboot_manifest) do
    <<-MANIFEST
      notify { 'step_1':
      }
      ~>
      reboot { 'now':
        when => refreshed,
        message => 'A different message',
      }
    MANIFEST
  end

  it 'Reboot Immediately with a Custom Message' do
    apply_manifest(reboot_manifest, catch_failures: true, debug: true) do |result|
      expect(result.stdout).to match(%r{shutdown -r \+1 \"A different message\"})
      expect(result.stdout).to match(%r{Scheduling system reboot with message: \"A different message\"})
    end
    expect(reboot_issued_or_cancelled(['-r', '+1', 'A different message'])).to be (true)
  end
end
