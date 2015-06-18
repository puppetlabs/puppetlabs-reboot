test_name "Reboot Module - POSIX Provider - Puppet Resume after Reboot"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
file { '/first.txt':
  ensure => file,
} ~>
reboot { 'first_reboot':
} ->
file { '/second.txt':
  ensure => file,
} ~>
reboot { 'second_reboot':
}
MANIFEST

remove_artifacts = <<-MANIFEST
file { '/first.txt':
  ensure => absent,
}
file { '/second.txt':
  ensure => absent,
}
MANIFEST

confine :except, :platform => 'windows'

teardown do
  step "Remove Test Artifacts"
  posix_agents.each { |agent|
    apply_manifest_on agent, remove_artifacts
  }
end

posix_agents.each do |agent|
  step "Attempt First Reboot"
  apply_manifest_on agent, reboot_manifest do |result|
    assert_match /\[\/first.txt\]\/ensure: created/,
      result.stdout, 'Expected file was not created'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)

  step "Resume After Reboot"
  apply_manifest_on agent, reboot_manifest do |result|
    assert_match /\[\/second.txt\]\/ensure: created/,
      result.stdout, 'Expected file was not created'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)

  step "Verify Manifest is Finished"
  apply_manifest_on agent, reboot_manifest

  #Verify that a shutdown has NOT been initiated.
  ensure_shutdown_not_scheduled(agent)
end
