test_name "Windows Reboot Module - Reboot Immediately"

#Shutdown abort command.
shutdown_abort = "cmd /c shutdown /a"

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
}
MANIFEST
	
confine :to, :platform => 'windows'

agents.each do |agent|
	step "Reboot Immediately with Refresh"

	#Apply the manifest.
	on agent, puppet('apply', '--debug'), :stdin => reboot_manifest

	#Snooze to give time for shutdown command to propagate.
	sleep 5
	
	#Expect the abort command to cancel the pending reboot.
	on agent, shutdown_abort, :acceptable_exit_codes => [0]
end