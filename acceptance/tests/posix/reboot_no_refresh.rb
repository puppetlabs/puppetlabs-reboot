test_name "Reboot Module - POSIX Provider - No Refresh"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
reboot { 'now':
}
MANIFEST

confine :except, :platform => 'windows'

posix_agents.each do |agent|
  step "Attempt to Reboot Computer without Refresh"

  #Apply the manifest.
  apply_manifest_on agent, reboot_manifest

  #Verify that a shutdown has NOT been initiated because reboot
  #was not refreshed.
  ensure_shutdown_not_scheduled(agent)
end
