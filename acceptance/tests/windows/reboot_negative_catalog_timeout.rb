test_name "Reboot Module - Windows Provider - Negative - Reboot Catalog Timeout"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
notify { 'step_1':
} ~>
reboot { 'now':
  apply => finished,
  catalog_apply_timeout => 1,
} ->
exec { 'c:\\windows\\system32\\ping.exe /n 4 127.0.0.1':
}
MANIFEST

confine :to, :platform => 'windows'

windows_agents.each do |agent|
  step "Attempt Reboot with a Short Catalog Timeout"

  #Apply the manifest.
  on(agent, puppet('apply', '--debug'), :stdin => reboot_manifest)

  #Verify that a shutdown has NOT been initiated.
  ensure_shutdown_not_scheduled(agent)
end
