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
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest do |result|
    case fact('kernel')
    when 'SunOS'
      expected_command = /shutdown -y -i 6 -g 60 \"A different message\"/
    else
      expected_command = /shutdown -r \+1 \"A different message\"/
    end
    assert_match expected_command,
      result.stdout, 'Expected reboot message is incorrect'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
