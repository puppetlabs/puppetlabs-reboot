test_name "Windows Reboot Module - Custom Timeout"

#Shutdown abort command.
shutdown_abort = "cmd /c shutdown /a"

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

agents.each do |agent|
  step "Reboot Immediately with a Custom Timeout"

  #Apply the manifest.
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest do |result|
    assert_match /shutdown\.exe  \/r \/t 120 \/d p:4:1/,
      result.stderr, 'Expected reboot timeout is incorrect'
  end

  #Snooze to give time for shutdown command to propagate.
  #Waiting 61 seconds guarantees that the default timeout is different.
  sleep 61

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  on agent, shutdown_abort, :acceptable_exit_codes => [0]
end
