test_name "Reboot Module - Windows Provider - Pending Reboot"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
reboot { 'now':
  when => pending
}
MANIFEST

pending_reboot_manifest = <<-MANIFEST
registry_key { 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired':
  ensure => present,
}
MANIFEST

undo_pending_reboot_manifest = <<-MANIFEST
registry_key { 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired':
  ensure => absent,
}
MANIFEST

confine :to, :platform => 'windows'

teardown do
  step "Undo the Registry Changes for Required Reboot"
  windows_agents.each { |agent|
    apply_manifest_on agent, undo_pending_reboot_manifest
  }
end

windows_agents.each do |agent|
  step "Declare Reboot Required in the Registry"
  apply_manifest_on agent,  pending_reboot_manifest

  step "Reboot if Pending Reboot Required"
  apply_manifest_on agent,  reboot_manifest

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end

windows_agents.each do |agent|
  original_name = nil

  begin
    step "Retrieve computer name"
    original_name = on(agent, 'cmd /c hostname').stdout.chomp

    new_name = ('a'..'z').to_a.shuffle[0, 12].join
    step "Rename the computer to #{new_name} temporarily"
    on agent, powershell("\"& { (Get-WmiObject -Class Win32_ComputerSystem).Rename('#{new_name}') }\"")

    step "Reboot if Pending Reboot Required"
    apply_manifest_on agent,  reboot_manifest

    #Verify that a shutdown has been initiated and clear the pending shutdown.
    retry_shutdown_abort(agent)
  ensure
    if original_name
      step "Rename the computer back to #{original_name}"
      on agent, powershell("\"& { (Get-WmiObject win32_computersystem).Rename('#{original_name}') }\"")
    end
  end
end
