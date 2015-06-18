test_name "Reboot Module - POSIX Provider - Custom Message"
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

confine :except, :platform => 'windows'

posix_agents.each do |agent|
  step "Reboot Immediately with a Custom Message"

  #Apply the manifest.
  apply_manifest_on agent, reboot_manifest, {:debug => true} do |result|
    if fact_on(agent, 'kernel') == 'SunOS'
      expected_command = /shutdown -y -i 6 -g 60 \"A different message\"/
    else
      expected_command = /shutdown -r \+1 \"A different message\"/
    end

    assert_match expected_command,
                 result.stdout, 'Expected reboot message is incorrect'
    assert_match /Scheduling system reboot with message: \"A different message\"/,
                 result.stdout, 'Reboot message was not logged'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
