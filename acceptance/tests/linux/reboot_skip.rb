test_name "Reboot Module - Linux Provider - Reboot Skip"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
notify { 'step_1':
} ~>
reboot { 'now':
} ->
notify { 'step_2':
}
MANIFEST

confine :except, :platform => 'windows'

linux_agents.each do |agent|
  step "Reboot Immediately with Skipping Other Resources"

  #Apply the manifest. Verify that the "step_2" notify is skipped.
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest do |result|
    assert_match /Transaction canceled, skipping/,
      result.stdout, 'Expected resource was not skipped'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
