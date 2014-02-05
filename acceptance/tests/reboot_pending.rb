test_name "Windows Reboot Module - Pending Reboot"

#Shutdown abort command.
shutdown_abort = "cmd /c shutdown /a"

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

agents.each do |agent|
  step "Declare Reboot Required in the Registry"
  on agent, puppet('apply', '--debug'), :stdin => pending_reboot_manifest

  step "Reboot if Pending Reboot Required"
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest

  #Snooze to give time for shutdown command to propagate.
  sleep 5

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  on agent, shutdown_abort, :acceptable_exit_codes => [0]
end
