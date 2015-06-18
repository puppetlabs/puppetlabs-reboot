test_name "Reboot Module - Windows Provider - Puppet Resume after Reboot"
extend Puppet::Acceptance::Reboot

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
  on windows_agents, puppet('apply', '--debug'), :stdin => remove_artifacts
end

windows_agents.each do |agent|
  step "Attempt First Reboot"
  apply_manifest_on agent,  reboot_manifest, {:debug => true} do |result|
    assert_match /\[c:\/first.txt\]\/ensure: created/,
      result.stdout, 'Expected file was not created'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)

  step "Resume After Reboot"
  apply_manifest_on agent, reboot_manifest, {:debug => true} do |result|
    assert_match /\[c:\/second.txt\]\/ensure: created/,
      result.stdout, 'Expected file was not created'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)

  step "Verify Manifest is Finished"
  apply_manifest_on agent, reboot_manifest

  #Verify that a shutdown has NOT been initiated.
  ensure_shutdown_not_scheduled(agent)
end
