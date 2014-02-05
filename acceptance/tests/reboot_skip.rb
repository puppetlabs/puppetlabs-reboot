test_name "Windows Reboot Module - Reboot Skip"

#Shutdown abort command.
shutdown_abort = "cmd /c shutdown /a"

reboot_manifest = <<-MANIFEST
notify { 'step_1':
} ~>
reboot { 'now':
} ->
notify { 'step_2':
}
MANIFEST

confine :to, :platform => 'windows'

agents.each do |agent|
  step "Reboot Immediately with Skipping Other Resources"

  #Apply the manifest. Verify that the "step_2" notify is skipped.
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest do |result|
    assert_match /Transaction canceled, skipping/,
      result.stdout, 'Expected resource was not skipped'
  end

  #Snooze to give time for shutdown command to propagate.
  sleep 5

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  on agent, shutdown_abort, :acceptable_exit_codes => [0]
end
