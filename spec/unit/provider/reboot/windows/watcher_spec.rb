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
    def expects_watcher_to_return(wait_result)
      watcher = Watcher.new(current_pid, timeout, command)
      watcher.expects(:waitpid).returns(wait_result)
      watcher
    end

    it "only executes when the watched process completes" do
      watcher = expects_watcher_to_return(Windows::Synchronize::WAIT_OBJECT_0)
      watcher.expects(:system).with(command)
      watcher.expects(:log_message).with("Process completed; executing '#{command}'.")

      watcher.execute
    end

    it "logs a message when the watched process times-out" do
      watcher = expects_watcher_to_return(Windows::Synchronize::WAIT_TIMEOUT)
      watcher.expects(:system).never
      watcher.expects(:log_message).with("Timed out waiting for process to exit; reboot aborted.")
      watcher.execute
    end

    it "logs a message when it fails to watch the process" do
      watcher = expects_watcher_to_return(Windows::Synchronize::WAIT_FAILED)
      watcher.expects(:system).never
      watcher.expects(:get_last_error).returns('Access is denied')
      watcher.expects(:log_message).with("Failed to wait on the process (Access is denied); reboot aborted.")
      watcher.execute
    end
  end
end
