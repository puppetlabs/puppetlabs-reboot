require 'spec_helper_acceptance'

describe 'Reboot Immediately and Explicit Immediately' do
  let(:reboot_manifest) do
    <<-MANIFEST
      notify { 'step_1':
      }
      ~>
      reboot { 'now':
      }
    MANIFEST
  end

  let(:reboot_immediate_manifest) do
    <<-MANIFEST
      notify { 'step_1':
      }
      ~>
      reboot { 'now':
        apply => immediately
      }
    MANIFEST
  end

  it 'Reboot Immediately with Refresh' do
    apply_manifest(reboot_manifest, catch_failures: true)
    expect(reboot_issued_or_cancelled).to eq(true)
  end

  it 'Reboot Immediately explicit with Refresh' do
    apply_manifest(reboot_immediate_manifest, catch_failures: true)
    expect(reboot_issued_or_cancelled).to eq(true)
  end
end
