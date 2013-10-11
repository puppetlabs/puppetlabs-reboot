test_name "Windows Reboot Module - Custom Message"

#Shutdown abort command.
shutdown_abort = "cmd /c shutdown /a"

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
  when => refreshed,
  message => 'A different message',
}
MANIFEST
	
confine :to, :platform => 'windows'

agents.each do |agent|
	step "Reboot Immediately with a Custom Message"

	#Apply the manifest.
	on agent, puppet('apply', '--debug'), :stdin => reboot_manifest do
		assert_match /shutdown\.exe  \/r \/t 60 \/d p:4:1 \/c \"A different message\"/, 
			result.output, 'Expected reboot message is incorrect'
	end

	#Snooze to give time for shutdown command to propagate.
	sleep 5
	
	#Expect the abort command to cancel the pending reboot.
	on agent, shutdown_abort, :acceptable_exit_codes => [0]
end