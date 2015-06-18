test_name "Reboot Module - Windows Provider - Reboot when Finished"
extend Puppet::Acceptance::Reboot

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

windows_agents.each do |agent|
  step "Reboot After Finishing Complete Catalog"

  #Apply the manifest.
  apply_manifest_on agent, reboot_manifest do |result|
    assert_match /defined 'message' as 'step_2'/,
                 result.stdout, 'Expected step was not finished before reboot'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
