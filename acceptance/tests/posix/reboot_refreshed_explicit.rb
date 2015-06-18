test_name "Reboot Module - POSIX Provider - Reboot when Refreshed Explicit"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
  when => refreshed
}
MANIFEST

confine :except, :platform => 'windows'

posix_agents.each do |agent|
  step "Reboot when Refreshed (Explicit)"

  #Apply the manifest.
  apply_manifest_on agent, reboot_manifest

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
