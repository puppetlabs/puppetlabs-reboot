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

  context "parameter :apply" do
    it "should default to :immediately" do
      resource[:apply].must == :immediately
    end

    it "should accept :finished" do
      resource[:apply] = :finished
    end

    it "should reject other values" do
      expect {
        resource[:apply] = :whenever
      }.to raise_error(Puppet::ResourceError, /Invalid value :whenever. Valid values are immediately/)
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

    it "should accept a 8000 character message" do
      resource[:message] = 'a' * 8000
    end

    it "should reject a 8001 character message" do
      expect {
        resource[:message] = 'a' * 8001
      }.to raise_error(Puppet::ResourceError, /The given message must not exceed 8000 characters./)
    end
  end

  context "parameter :prompt" do
    it "should default to nil" do
      resource[:prompt].must be_nil
    end

    it "should accept true on platforms that support prompting" do
      reboot = Puppet::Type.type(:reboot).new(:name => 'reboot', :provider => :windows)
      reboot[:prompt] = true
    end

    it "should reject non-boolean values on platforms that support prompting" do
      reboot = Puppet::Type.type(:reboot).new(:name => 'reboot', :provider => :windows)
      expect {
        reboot[:prompt] = "I'm not sure"
      }.to raise_error(Puppet::ResourceError, /Invalid value "I'm not sure"/)
    end
  end

  context "parameter :catalog_apply_timeout" do
    it "should default to 7200 seconds" do
      resource[:catalog_apply_timeout].must == 7200
    end

    it "should accept 30 minute timeout" do
      resource[:catalog_apply_timeout] = 30 * 60
    end

    ["later", :later, {}, [], true].each do |timeout|
      it "should reject a non-integer (#{timeout.class}) value" do
        expect {
          resource[:catalog_apply_timeout] = timeout
        }.to raise_error(Puppet::ResourceError, /The catalog_apply_timeout must be an integer/)
      end
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
