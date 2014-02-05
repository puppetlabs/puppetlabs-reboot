test_name "Windows Reboot Module - Reboot when Refreshed Explicit"

#Shutdown abort command.
shutdown_abort = "cmd /c shutdown /a"

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
  when => refreshed
}
MANIFEST

confine :to, :platform => 'windows'

agents.each do |agent|
  step "Reboot when Refreshed (Explicit)"

  #Apply the manifest.
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest

  #Snooze to give time for shutdown command to propagate.
  sleep 5

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  on agent, shutdown_abort, :acceptable_exit_codes => [0]
end
