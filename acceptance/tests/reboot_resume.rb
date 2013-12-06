test_name "Windows Reboot Module - Puppet Resume after Reboot"

#Shutdown abort command.
shutdown_abort = "cmd /c shutdown /a"

reboot_manifest = <<-MANIFEST
file { 'c:/first.txt':
  ensure => file,
} ~>
reboot { 'first_reboot':
} ->
file { 'c:/second.txt':
  ensure => file,
} ~>
reboot { 'second_reboot':
}
MANIFEST

remove_artifacts = <<-MANIFEST
file { 'c:/first.txt':
  ensure => absent,
}
file { 'c:/second.txt':
  ensure => absent,
}
MANIFEST

confine :to, :platform => 'windows'

teardown do
	step "Remove Test Artifacts"
	on agents, puppet('apply', '--debug'), :stdin => remove_artifacts
end

agents.each do |agent|
	step "Attempt First Reboot"
	on agent, puppet('apply', '--debug'), :stdin => reboot_manifest do
		assert_match /\[c:\/first.txt\]\/ensure: created/, 
			result.stdout, 'Expected file was not created'
	end

	#Snooze to give time for shutdown command to propagate.
	sleep 5
	
	#Expect the abort command to cancel the pending reboot.
	on agent, shutdown_abort, :acceptable_exit_codes => [0]
	
	step "Resume After Reboot"
	on agent, puppet('apply', '--debug'), :stdin => reboot_manifest do
		assert_match /\[c:\/second.txt\]\/ensure: created/, 
			result.stdout, 'Expected file was not created'
	end

	#Snooze to give time for shutdown command to propagate.
	sleep 5
	
	#Expect the abort command to cancel the pending reboot.
	on agent, shutdown_abort, :acceptable_exit_codes => [0]

	step "Verify Manifest is Finished"
	on agent, puppet('apply', '--debug'), :stdin => reboot_manifest

	#Snooze to give time for shutdown command to propagate.
	sleep 5
	
	#Expect the abort command to fail because there are no pending reboots.
	on agent, shutdown_abort, :acceptable_exit_codes => [92]
end