#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/reboot/windows'

describe Puppet::Type.type(:reboot).provider(:windows), :if => Puppet.features.microsoft_windows? do
  let(:resource) { Puppet::Type.type(:reboot).new(:provider => :windows, :name => "windows_reboot") }
  let(:provider) { resource.provider}
  let(:native_path)     { "#{ENV['SYSTEMROOT']}\\sysnative\\shutdown.exe" }
  let(:redirected_path) { "#{ENV['SYSTEMROOT']}\\system32\\shutdown.exe" }

  before :each do
    resource.class.rebooting = false
  end

  it "should be an instance of Puppet::Type::Reboot::ProviderWindows" do
    provider.must be_an_instance_of Puppet::Type::Reboot::ProviderWindows
  end

  context "self.instances" do
    it "should return an empty array" do
      provider.class.instances.should == []
    end
  end

  context "when resolving the shutdown command" do
    it "should try to disable file system redirection" do
      File.expects(:exists?).with(native_path).returns(true)
      expect(provider.class.shutdown_command).to eq(native_path)
    end

    it "should fall back to system32" do
      File.expects(:exists?).with(native_path).returns(false)
      File.expects(:exists?).with(redirected_path).returns(true)
      expect(provider.class.shutdown_command).to eq(redirected_path)
    end

    it "should use 'shutdown.exe'" do
      File.expects(:exists?).with(native_path).returns(false)
      File.expects(:exists?).with(redirected_path).returns(false)
      expect(provider.class.shutdown_command).to eq('shutdown.exe')
    end

    it "should raise an error if shutdown.exe cannot be found" do
      provider.expects(:command).with(:shutdown).returns(nil)
      provider.expects(:async_shutdown).never

      expect {
        provider.reboot
      }.to raise_error(ArgumentError, 'The shutdown.exe command was not found. On Windows 2003 x64 hotfix 942589 must be installed to access the 64-bit version of shutdown.exe from 32-bit version of ruby.exe.')
    end
  end

  context "when checking if the `when` property is insync" do
    it "is absent by default" do
      expect(provider.when).to eq(:absent)
    end

    it "should not reboot when setting the `when` property to refreshed" do
      provider.expects(:reboot).never

      provider.when = :refreshed
    end

    it "issues a shutdown command when a reboot is pending" do
      resource[:when] = :pending

      provider.expects(:command).with(:shutdown).returns(native_path)
      provider.expects(:async_shutdown).with(includes('shutdown.exe'))

      provider.when = :pending
    end
  end

  context "when a reboot is triggered", :if => Puppet::Util.which('shutdown.exe') do
    before :each do
      provider.expects(:async_shutdown).with(includes('shutdown.exe')).at_most_once
    end

    it "stops the application by default" do
      Puppet::Application.expects(:stop!)
      provider.reboot
    end

    context "when apply is set to finished and when is set to pending" do
      it "throws an unsupported warning" do
        resource[:when] = :pending
        resource[:apply] = :finished
        Puppet.expects(:warning).with(includes('The combination'))
        provider.reboot
      end
    end

    it "cancels the rest of the catalog transaction if apply is set to immediately" do
      resource[:apply] = :immediately
      Puppet::Application.expects(:stop!)
      provider.reboot
    end

    it "doesn't stop the rest of the catalog transaction if apply is set to finished" do
      resource[:apply] = :finished
      Puppet::Application.expects(:stop!).never
      provider.reboot
    end

    it "does not include the interactive flag" do
      provider.expects(:async_shutdown).with(Not(includes('/i')))
      provider.reboot
    end

    it "includes the restart flag" do
      provider.expects(:async_shutdown).with(includes('/r'))
      provider.reboot
    end

    it "includes a timeout in the future" do
      provider.expects(:async_shutdown).with(includes("/t #{resource[:timeout]}"))
      provider.reboot
    end

    it "includes the shutdown reason as Application Maintenance (Planned)" do
      provider.expects(:async_shutdown).with(includes("/d p:4:1"))
      provider.reboot
    end

    it "includes the quoted reboot message" do
      resource[:message] = "triggering a reboot"
      provider.expects(:async_shutdown).with(includes('"triggering a reboot"'))
      provider.reboot
    end

    context "multiple triggered reboots" do
      let(:resource2) { Puppet::Type.type(:reboot).new(:provider => :windows, :name => "windows_reboot2") }
      let(:provider2) { resource2.provider }

      context "where the second resource has when set to pending" do
        before :each do
          resource2[:when] = :pending
        end

        context "where the first resource has apply set to finished" do
          before :each do
            resource[:apply] = :finished
          end

          it "should only reboot once" do
            resource[:when] = :refreshed
            provider.expects(:reboot)

            resource.refresh

            provider2.expects(:reboot).never
            Puppet.expects(:debug).with(includes('already scheduled'))
            provider2[:when] = :pending
          end

          it "should only reboot once when the first resource has when set to pending" do
            # this isn't supported but no harm testing that it doesn't blow up
            resource[:when] = :pending
            provider.expects(:reboot)
            Puppet.expects(:warning).with(includes('The combination'))
            provider[:when] = :pending

            provider2.expects(:reboot).never
            Puppet.expects(:debug).with(includes('already scheduled'))
            provider2[:when] = :pending
          end
        end
      end
    end
  end

  context "when detecting if a reboot is pending" do
    def expects_registry_key(path)
      Win32::Registry::HKEY_LOCAL_MACHINE.expects(:open).with(path, anything)
    end

    def expects_registry_key_not_found(path)
      Win32::Registry::HKEY_LOCAL_MACHINE.expects(:open).with(path, anything).raises(Win32::Registry::Error, 5)
    end

    def expects_registry_value(path, name, value)
      reg = stub('reg')
      reg.expects(:read).with(name).returns(value)
      expects_registry_key(path).yields(reg)
    end

    def expects_registry_value_not_found(path, name)
      reg = stub('reg')
      reg.expects(:read).with(name).raises(Win32::Registry::Error, 5)
      expects_registry_key(path).yields(reg)
    end

    context 'Component-Based Servicing' do
      it 'ignores on Vista and earlier' do
        provider.expects(:vista_sp1_or_later?).returns false

        provider.should_not be_component_based_servicing
      end

      context 'when Vista SP1 and up' do
        let(:path) { 'SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }

        it 'reboots if the RebootPending key is present' do
          provider.expects(:vista_sp1_or_later?).returns true
          expects_registry_key(path).yields(stub('reg'))

          provider.should be_component_based_servicing
        end

        it 'ignores if the RebootPending key is absent' do
          provider.expects(:vista_sp1_or_later?).returns true
          expects_registry_key_not_found(path)

          provider.should_not be_component_based_servicing
        end
      end
    end

    context 'Auto Updates' do
      let(:path) { 'SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' }

      it 'reboots if the RebootRequired key is present' do
        expects_registry_key(path).yields(stub('reg'))

        provider.should be_windows_auto_update
      end

      it 'ignores if the RebootRequired key is absent' do
        expects_registry_key_not_found(path)

        provider.should_not be_windows_auto_update
      end
    end

    context 'Pending file rename operations' do
      let(:path) { 'SYSTEM\CurrentControlSet\Control\Session Manager' }
      let(:name) { 'PendingFileRenameOperations' }

      it 'reboots if the value exists and is non-empty' do
        expects_registry_value(path, name, ['C:/from','C:/to'])

        provider.should be_pending_file_rename_operations
      end

      it 'ignores if the key is absent' do
        expects_registry_key_not_found(path)

        provider.should_not be_pending_file_rename_operations
      end

      it 'ignores if the value is absent' do
        expects_registry_value_not_found(path, name)

        provider.should_not be_pending_file_rename_operations
      end

      it 'ignores if the value is empty' do
        expects_registry_value(path, name, [])

        provider.should_not be_pending_file_rename_operations
      end
    end

    context 'Package installer' do
      let(:name) { 'UpdateExeVolatile' }

      context 'update.exe (native x86/x64)' do
        let(:path) { 'SOFTWARE\Microsoft\Updates' }

        it 'reboots if the UpdateExeVolatile value exists and is non-zero' do
          expects_registry_value(path, name, 1)

          provider.should be_package_installer
        end

        it 'ignores if the UpdateExeVolatile value exists and is zero' do
          expects_registry_value(path, name, 0)

          provider.should_not be_package_installer
        end

        it 'ignores if the UpdateExeVolatile value is absent' do
          expects_registry_value_not_found(path, name)

          provider.should_not be_package_installer
        end
      end

      context 'update.exe (syswow64)' do
        let(:path) { 'SOFTWARE\Wow6432Node\Microsoft\Updates' }

        it 'reboots if the UpdateExeVolatile value exists and is non-zero' do
          expects_registry_value(path, name, 1)

          provider.should be_package_installer_syswow64
        end

        it 'ignores if the UpdateExeVolatile value exists and is zero' do
          expects_registry_value(path, name, 0)

          provider.should_not be_package_installer_syswow64
        end

        it 'ignores if the UpdateExeVolatile value is absent' do
          expects_registry_value_not_found(path, name)

          provider.should_not be_package_installer_syswow64
        end
      end
    end
  end

end
