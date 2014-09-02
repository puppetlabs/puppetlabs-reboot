#! /usr/bin/env ruby
require 'spec_helper'

describe 'Watcher', :if => Puppet.features.microsoft_windows? do

  require 'puppet/provider/reboot/windows/watcher.rb'

  let(:current_pid) { Process.pid }
  let(:bogus_pid) { 0xFFFFFFFF }
  let(:one_second) { 1 }
  let(:command) { 'cmd.exe /c echo hello' }

  before :each do
    Watcher.any_instance.stubs(:log_message)
  end

  it "parses its command line arguments" do
    watcher = Watcher.new([current_pid, one_second, command])

    watcher.pid.should == current_pid
    watcher.timeout.should == one_second
    watcher.command.should == command
  end

  context "when waiting for a process" do
    it "waits for the process to finish", :unless => RUBY_VERSION[0,3] == '1.8' do
      pid = spawn("ruby.exe -e 'sleep #{one_second}'")
      watcher = Watcher.new([pid, 5 * one_second, command])

      watcher.waitpid.should == Watcher::WAIT_OBJECT_0
    end

    it "returns `WAIT_TIMEOUT` if the process times out" do
      watcher = Watcher.new([current_pid, one_second, command])

      watcher.waitpid.should == Watcher::WAIT_TIMEOUT
    end

    it "returns `WAIT_FAILED` if it waits on a process it can't access" do
      watcher = Watcher.new([bogus_pid, one_second, command])

      FFI.expects(:errno).returns(5)

      watcher.waitpid.should == Watcher::WAIT_FAILED
    end

    it "returns `WAIT_OBJECT_0` if the process has already exited" do
      watcher = Watcher.new([0, one_second, command])

      FFI.expects(:errno).returns(Watcher::ERROR_INVALID_PARAMETER)

      watcher.waitpid.should == Watcher::WAIT_OBJECT_0
    end
  end

  context "when executing the command" do
    def expects_watcher_to_return(wait_result)
      watcher = Watcher.new([current_pid, one_second, command])
      watcher.expects(:waitpid).returns(wait_result)
      watcher
    end

    it "only executes when the watched process completes" do
      watcher = expects_watcher_to_return(Watcher::WAIT_OBJECT_0)
      watcher.expects(:system).with(command)
      watcher.expects(:log_message).with("Process completed; executing '#{command}'.")

      watcher.execute
    end

    it "logs a message when the watched process times-out" do
      watcher = expects_watcher_to_return(Watcher::WAIT_TIMEOUT)
      watcher.expects(:system).never
      watcher.expects(:log_message).with("Timed out waiting for process to exit; reboot aborted.")
      watcher.execute
    end

    it "logs a message when it fails to watch the process" do
      watcher = expects_watcher_to_return(Watcher::WAIT_FAILED)
      watcher.expects(:system).never
      watcher.expects(:get_last_error).returns('Access is denied')
      watcher.expects(:log_message).with("Failed to wait on the process (Access is denied); reboot aborted.")
      watcher.execute
    end
  end
end
