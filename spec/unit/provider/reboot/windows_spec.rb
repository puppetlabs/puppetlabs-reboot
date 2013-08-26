#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/reboot/windows'

describe Puppet::Type.type(:reboot).provider(:windows), :if => Puppet.features.microsoft_windows? do
  let(:resource) { Puppet::Type.type(:reboot).new(:provider => :windows, :name => "windows_reboot") }
  let (:provider) { resource.provider}

  it "should be an instance of Puppet::Type::Reboot::ProviderWindows" do
    provider.must be_an_instance_of Puppet::Type::Reboot::ProviderWindows
  end

  context "self.instances" do
    it "should return an empty array" do
      provider.class.instances.should == []
    end
  end

  context "when checking if the `when` property is insync" do
    it "issues a shutdown command" do
      resource[:when] = :pending

      provider.expects(:shutdown)

      provider.when = :pending
    end
  end

  context "when a reboot is triggered" do
    it "should include the quoted reboot message" do
      resource[:message] = "triggering a reboot"

      provider.expects(:shutdown).with(includes('"triggering a reboot"'))

      provider.reboot
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
