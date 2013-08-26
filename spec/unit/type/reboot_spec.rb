#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/type/reboot'

describe Puppet::Type.type(:reboot) do
  let(:resource) { Puppet::Type.type(:reboot).new(:name => "reboot") }
  let(:provider) { Puppet::Provider.new(resource) }

  before :each do
    resource.provider = provider
  end

  it "should be an instance of Puppet::Type::Reboot" do
    resource.must be_an_instance_of Puppet::Type::Reboot
  end

  context "when refreshed" do
    it "should only reboot if the `when` parameter is `refreshed`" do
      resource[:when] = :refreshed
      resource.provider.expects(:reboot)

      resource.refresh
    end

    it "should not reboot if the `when` parameter is `pending`" do
      resource.provider.expects(:satisfies?).with([:manages_reboot_pending]).returns(true)
      resource.provider.expects(:reboot).never
      resource[:when] = :pending

      resource.refresh
    end
  end

  context "parameter :when" do
    it "should default to :refreshed" do
      resource[:when].must == :refreshed
    end

    it "should accept :pending" do
      resource.provider.expects(:satisfies?).with([:manages_reboot_pending]).returns(true)

      resource[:when] = :pending
    end

    it "should reject other values" do
      expect {
        resource[:when] = :whenever
      }.to raise_error(Puppet::ResourceError, /Invalid value :whenever. Valid values are refreshed/)
    end
  end

  context "parameter :message" do
    it "should default to \"Puppet is rebooting the computer\"" do
      resource[:message].must == "Puppet is rebooting the computer"
    end

    it "should accept a custom message" do
      resource[:message] = "This is a different message"
    end

    it "should reject an empty value" do
      expect {
        resource[:message] = ""
      }.to raise_error(Puppet::ResourceError, /A non-empty message must be specified./)
    end
  end

  context "parameter :prompt" do
    it "should default to nil" do
      resource[:prompt].must be_nil
    end

    it "should accept true" do
      resource[:prompt] = true
    end

    it "should reject non-boolean values" do
      expect {
        resource[:prompt] = "I'm not sure"
      }.to raise_error(Puppet::ResourceError, /Invalid value "I'm not sure"/)
    end
  end

  context "parameter :timeout" do
    it "should default :timeout to 60 seconds" do
      resource[:timeout].must == 60
    end

    it "should accept 30 minute timeout" do
      resource[:timeout] = 30 * 60
    end

    ["later", :later, {}, [], true].each do |timeout|
      it "should reject a non-integer (#{timeout.class}) value" do
        expect {
          resource[:timeout] = timeout
        }.to raise_error(Puppet::ResourceError, /The timeout must be an integer/)
      end
    end
  end
end
