test_name "Windows Reboot Module - Negative - Incompatible with Linux"

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
}
MANIFEST

confine :except, :platform => 'windows'

agents.select { |agent| agent['platform'].include?('windows') }.each do |agent|
  step "Attempt to Reboot on Linux"

  #Apply the manifest.
  on agent, puppet('apply', '--debug', :stdin => reboot_manifest) do |result|
    assert_match /Error: Could not find a suitable provider for reboot/,
                 result.stderr, 'Expected error message is missing'
  end
end
