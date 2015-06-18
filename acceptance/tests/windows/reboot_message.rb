test_name "Reboot Module - Windows Provider - Custom Message"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
  when => refreshed,
  message => 'A different message',
}
MANIFEST

confine :to, :platform => 'windows'

windows_agents.each do |agent|
  step "Reboot Immediately with a Custom Message"

  #Apply the manifest.
  apply_manifest_on agent, reboot_manifest, {:debug => true} do |result|
    assert_match /shutdown\.exe \/r \/t 60 \/d p:4:1 \/c \"A different message\"/,
                 result.stdout, 'Expected reboot message is incorrect'
    assert_match /Scheduling system reboot with message: \"A different message\"/,
                 result.stdout, 'Reboot message was not logged'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
