#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/reboot/base'

describe Puppet::Type.type(:reboot).provider(:base) do
  let (:resource) { Puppet::Type.type(:reboot).new(:message=> 'yo', :provider => :base, :name => "base_reboot") }
  let (:provider) { resource.provider }

  it "should be an instance of Puppet::Type::Reboot::ProviderBase" do
    provider.must be_an_instance_of Puppet::Type::Reboot::ProviderBase
  end

  context "when checking if the `when` property is insync" do
    it "should not reboot when setting the `when` property to refreshed" do
      provider.expects(:reboot).never

      provider.when = :refreshed
    end
  end

  context "when a reboot is triggered" do
    it "should request that the application stop" do
      Puppet::Application.expects(:stop!)

      provider.reboot
    end
  end
end
