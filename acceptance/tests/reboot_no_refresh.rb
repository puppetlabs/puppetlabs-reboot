test_name "Windows Reboot Module - No Refresh"

#Shutdown abort command.
shutdown_abort = "cmd /c shutdown /a"

reboot_manifest = <<-MANIFEST
reboot { 'now':
}
MANIFEST

confine :to, :platform => 'windows'

agents.each do |agent|
  step "Attempt to Reboot Computer without Refresh"

  #Apply the manifest.
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest

  #Snooze to give time for shutdown command to propagate.
  sleep 5

  #Verify that a shutdown has NOT been initiated because reboot
  #was not refreshed.
  on agent, shutdown_abort, :acceptable_exit_codes => [92]
end
