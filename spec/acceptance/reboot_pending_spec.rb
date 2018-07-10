require 'spec_helper_acceptance'

describe 'Windows Provider - Pending Reboot' do
  let(:reboot_manifest) do
    <<-MANIFEST
      reboot { 'now':
        when => pending
      }
    MANIFEST
  end
  let(:pending_reboot_manifest) do
    <<-MANIFEST
      registry_key { 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired':
        ensure => present,
      }
    MANIFEST
  end

  # Undo the Registry Changes for Required Reboot
  after(:all) do
    undo_pending_reboot_manifest = <<-MANIFEST
      registry_key { 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired':
        ensure => absent,
      }
      MANIFEST
    windows_agents.each do |agent|
      execute_manifest_on(agent, undo_pending_reboot_manifest)
    end
  end

  windows_agents.each do |agent|
    context "Agent #{agent}" do
      it 'Declare Reboot Required in the Registry' do
        execute_manifest_on(agent, pending_reboot_manifest)
      end

      it 'Reboot if Pending Reboot Required' do
        execute_manifest_on(agent, reboot_manifest)
        retry_shutdown_abort(agent)
      end
    end
  end

  windows_agents.each do |agent|
    context "on #{agent}" do
      original_name = on(agent, 'cmd /c hostname').stdout.chomp

      new_name = ('a'..'z').to_a.sample(12).join
      it "Rename the computer to #{new_name} temporarily" do
        on agent, powershell("\"& { (Get-WmiObject -Class Win32_ComputerSystem).Rename('#{new_name}') }\"")
      end
      it 'Reboot if Pending Reboot Required' do
        execute_manifest_on(agent, reboot_manifest)
        retry_shutdown_abort(agent)
      end
      if original_name
        it "Rename the computer back to #{original_name}" do
          on agent, powershell("\"& { (Get-WmiObject win32_computersystem).Rename('#{original_name}') }\"")
        end
      end
    end
  end
end
