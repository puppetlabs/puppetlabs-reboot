test_name "Reboot Module - Windows Provider - Pending Reboot"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
reboot { 'now':
  when => pending
}
MANIFEST

pending_reboot_manifest = <<-MANIFEST
registry_key { 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired':
  ensure => present,
}
MANIFEST

undo_pending_reboot_manifest = <<-MANIFEST
registry_key { 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired':
  ensure => absent,
}
MANIFEST

confine :to, :platform => 'windows'

teardown do
  step "Undo the Registry Changes for Required Reboot"
  on agents, puppet('apply', '--debug'), :stdin => undo_pending_reboot_manifest
end

windows_agents.each do |agent|
  step "Declare Reboot Required in the Registry"
  on agent, puppet('apply', '--debug'), :stdin => pending_reboot_manifest

  step "Reboot if Pending Reboot Required"
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
