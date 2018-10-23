require_relative '../../../tasks/init'

describe Reboot::Task do # rubocop:disable RSpec/FilePath
  context 'on Windows' do
    before(:each) { Facter.stubs(:value).with(:kernel).returns('windows') }

    context 'when rebooting' do
      let(:reboot) { described_class.new }

      it 'runs the correct command' do
        command = 'shutdown.exe /r /t 3 /d p:4:1 '
        reboot.expects(:shutdown_executable_windows).returns('shutdown.exe')
        reboot.expects(:async_command).with(command).returns(nil)
        reboot.execute!
      end

      context 'with a timeout' do
        let(:reboot) { described_class.new('timeout' => 20) }

        it 'handles the timeout' do
          command = 'shutdown.exe /r /t 20 /d p:4:1 '
          reboot.expects(:shutdown_executable_windows).returns('shutdown.exe')
          reboot.expects(:async_command).with(command).returns(nil)
          reboot.execute!
        end

        it 'does not allow timeouts < 3' do
          reboot = described_class.new('timeout' => 0)
          command = 'shutdown.exe /r /t 3 /d p:4:1 '
          reboot.expects(:shutdown_executable_windows).returns('shutdown.exe')
          reboot.expects(:async_command).with(command).returns(nil)
          reboot.execute!
        end
      end
    end

    context 'when shutting down' do
      let(:reboot) { described_class.new('shutdown_only' => true) }

      it 'runs the correct command' do
        command = 'shutdown.exe /s /t 3 /d p:4:1 '
        reboot.expects(:shutdown_executable_windows).returns('shutdown.exe')
        reboot.expects(:async_command).with(command).returns(nil)
        reboot.execute!
      end
    end
  end

  context 'on Solaris' do
    before(:each) { Facter.stubs(:value).with(:kernel).returns('SunOS') }

    context 'when rebooting' do
      let(:reboot) { described_class.new }

      it 'runs the correct command' do
        command = ['shutdown', '-y', '-i', '6', '-g', 0, "''", '</dev/null', '>/dev/null', '2>&1', '&']
        reboot.expects(:async_command).with(command).returns(nil)
        reboot.execute!
      end

      context 'with a timeout' do
        let(:reboot) { described_class.new('timeout' => 20) }

        it 'handles the timeout' do
          command = ['shutdown', '-y', '-i', '6', '-g', 20, "''", '</dev/null', '>/dev/null', '2>&1', '&']
          reboot.expects(:async_command).with(command).returns(nil)
          reboot.execute!
        end
      end
    end

    context 'when shutting down' do
      let(:reboot) { described_class.new('shutdown_only' => true) }

      it 'runs the correct command' do
        command = ['shutdown', '-y', '-i', '5', '-g', 0, "''", '</dev/null', '>/dev/null', '2>&1', '&']
        reboot.expects(:async_command).with(command).returns(nil)
        reboot.execute!
      end
    end
  end

  context 'on Linux' do
    before(:each) { Facter.stubs(:value).with(:kernel).returns('Linux') }

    context 'when rebooting' do
      let(:reboot) { described_class.new }

      it 'runs the correct command' do
        command = ['shutdown', '-r', '+0', "''", '</dev/null', '>/dev/null', '2>&1', '&']
        reboot.expects(:async_command).with(command).returns(nil)
        reboot.execute!
      end

      context 'with a timeout' do
        let(:reboot) { described_class.new('timeout' => 20) }

        it 'handles the timeout by rounding up' do
          command = ['shutdown', '-r', '+1', "''", '</dev/null', '>/dev/null', '2>&1', '&']
          reboot.expects(:async_command).with(command).returns(nil)
          reboot.execute!
        end
      end
    end

    context 'when shutting down' do
      let(:reboot) { described_class.new('shutdown_only' => true) }

      it 'runs the correct command' do
        command = ['shutdown', '-P', '+0', "''", '</dev/null', '>/dev/null', '2>&1', '&']
        reboot.expects(:async_command).with(command).returns(nil)
        reboot.execute!
      end
    end
  end
end
