test_name "Reboot Module - POSIX Provider - Custom Timeout"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
  when => refreshed,
  timeout => 120,
}
MANIFEST

confine :except, :platform => 'windows'

posix_agents.each do |agent|
  step "Reboot Immediately with a Custom Timeout"

  #Apply the manifest.
  apply_manifest_on agent, reboot_manifest, {:debug => true} do |result|
    if fact_on(agent, 'kernel') == 'SunOS'
      expected_command = /shutdown -y -i 6 -g 120/
    else
      expected_command = /shutdown -r \+2/
    end

    assert_match expected_command,
      result.stdout, 'Expected reboot timeout is incorrect'
  end

  #Waiting 61 seconds guarantees that the default timeout is different.
  sleep 61

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
