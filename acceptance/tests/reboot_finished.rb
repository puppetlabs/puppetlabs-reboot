test_name "Windows Reboot Module - Reboot when Finished"

#Shutdown abort command.
shutdown_abort = "cmd /c shutdown /a"

reboot_manifest = <<-MANIFEST
notify { 'step_1':
} ~>
reboot { 'now':
  apply => finished
} ->
notify { 'step_2':
}
MANIFEST

confine :to, :platform => 'windows'

agents.each do |agent|
	step "Reboot After Finishing Complete Catalog"

	#Apply the manifest.
	on agent, puppet('apply', '--debug'), :stdin => reboot_manifest do
		assert_match /defined 'message' as 'step_2'/, 
			result.stdout, 'Expected step was not finished before reboot'
	end

	#Snooze to give time for shutdown command to propagate.
	sleep 5
	
	#Expect the abort command to cancel the pending reboot.
	on agent, shutdown_abort, :acceptable_exit_codes => [0]
end