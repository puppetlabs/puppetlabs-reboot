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

  context "when a reboot is triggered" do
    it "should include the quoted reboot message" do
      resource[:message] = "triggering a reboot"

      provider.expects(:shutdown).with(includes('"triggering a reboot"'))

      provider.reboot
    end
  end
end
