test_name "Reboot Module - Windows Provider - Custom Timeout"
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

confine :to, :platform => 'windows'

windows_agents.each do |agent|
  step "Reboot Immediately with a Custom Timeout"

  #Apply the manifest.
  apply_manifest_on agent, reboot_manifest, {:debug => true} do |result|
    assert_match /shutdown\.exe \/r \/t 120 \/d p:4:1/,
      result.stdout, 'Expected reboot timeout is incorrect'
  end

  #Waiting 61 seconds guarantees that the default timeout is different.
  sleep 61

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
