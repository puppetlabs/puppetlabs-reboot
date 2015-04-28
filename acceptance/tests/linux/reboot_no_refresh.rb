test_name "Reboot Module - Linux Provider - No Refresh"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
reboot { 'now':
  provider => linux
}
MANIFEST

confine :except, :platform => 'windows' do |agent|
  fact_on(agent, 'kernel') == 'Linux'
end

linux_agents.each do |agent|
  step "Attempt to Reboot Computer without Refresh"

  #Apply the manifest.
  on agent, puppet('apply', '--debug'), :stdin => reboot_manifest

  #Verify that a shutdown has NOT been initiated because reboot
  #was not refreshed.
  ensure_shutdown_not_scheduled(agent)
end
