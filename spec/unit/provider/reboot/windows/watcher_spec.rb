#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/provider/reboot/windows/watcher.rb'

describe Watcher, :if => Puppet.features.microsoft_windows? do
  let(:current_pid) { Process.pid }
  let(:bogus_pid) { 0xFFFFFFFF }
  let(:timeout) { 1 }
  let(:command) { 'cmd.exe /c echo hello' }

  before :each do
    Watcher.any_instance.stubs(:log_message)
  end

  def to_stream(pid, timeout, command)
    io = StringIO.new
    io.puts(current_pid)
    io.puts(timeout)
    io.write(command)
    io.rewind
    io
  end

  it "loads itself from an IO stream" do
    watcher = Watcher.load(to_stream(current_pid, timeout, command))

    watcher.pid.should == current_pid
    watcher.timeout.should == timeout
    watcher.command.should == command
  end

  context "when waiting for a process" do
    it "waits for the process to finish" do
      pid = spawn("ruby.exe -e 'sleep #{timeout}'")
      Process.detach(pid)
      watcher = Watcher.new(pid, 2 * timeout, command)

      watcher.waitpid.should == Windows::Synchronize::WAIT_OBJECT_0
    end

    it "returns `WAIT_TIMEOUT` if the process times out" do
      watcher = Watcher.new(current_pid, timeout, command)

      watcher.waitpid.should == Windows::Synchronize::WAIT_TIMEOUT
    end

    it "returns `WAIT_FAILED` if it waits on a non-existent process" do
      watcher = Watcher.new(bogus_pid, 1, command)

      watcher.waitpid.should == Windows::Synchronize::WAIT_FAILED
    end
  end

  context "when executing the command" do
    it "executes when waiting on a non-existent process" do
      watcher = Watcher.new(bogus_pid, 0, command)
      watcher.expects(:system).with(command)
      watcher.execute
    end
  end
end
