require 'spec_helper'

# Tests generally use 0 timeouts to skip sleep in plans.
describe 'reboot plan', bolt: true do
  if ENV['GEM_BOLT']
    include BoltSpec::Plans
    # Fix wait_until_available, it's broken in Bolt 1.3.0.
    BoltSpec::Plans::MockExecutor.class_eval do
      def wait_until_available(targets, _options)
        Bolt::ResultSet.new(targets.map { |target| Bolt::Result.new(target) })
      end
    end
  end

  it 'reboots a target' do
    time_seq = [Time.now - 1, Time.now]
    expect_task('reboot::last_boot_time').return { |targets:, **|
      next_time = time_seq.shift
      Bolt::ResultSet.new(targets.map { |target| Bolt::Result.new(target, message: next_time.to_s) })
    }.be_called_times(2)
    expect_task('reboot').always_return('status' => 'queued', 'timeout' => 0)

    result = run_plan('reboot', 'nodes' => 'foo,bar', 'disconnect_wait' => 0)
    expect(result.value).to eq(nil)
  end

  it 'reboots a target that takes awhile to reboot' do
    reboot_time = Time.now
    start_time = reboot_time - 1
    time_seq = [start_time, start_time, reboot_time]
    expect_task('reboot::last_boot_time').return { |targets:, **|
      next_time = time_seq.shift
      Bolt::ResultSet.new(targets.map { |target| Bolt::Result.new(target, message: next_time.to_s) })
    }.be_called_times(3)
    expect_task('reboot').always_return('status' => 'queued', 'timeout' => 0)

    result = run_plan('reboot', 'nodes' => 'foo,bar', 'disconnect_wait' => 0)
    expect(result.value).to eq(nil)
  end

  it 'waits until all targets have rebooted' do
    reboot_time = Time.now
    start_time = reboot_time - 1
    time_seq = [[start_time, start_time], [start_time, reboot_time], [reboot_time]]
    expect_task('reboot::last_boot_time').return { |targets:, **|
      Bolt::ResultSet.new(targets.zip(time_seq.shift).map { |targ, time| Bolt::Result.new(targ, message: time.to_s) })
    }.be_called_times(3)
    expect_task('reboot').always_return('status' => 'queued', 'timeout' => 0)

    result = run_plan('reboot', 'nodes' => 'foo,bar', 'disconnect_wait' => 0)
    expect(result.value).to eq(nil)
  end

  it 'accepts extra arguments' do
    time_seq = [Time.now - 1, Time.now]
    expect_task('reboot::last_boot_time').return { |targets:, **|
      next_time = time_seq.shift
      Bolt::ResultSet.new(targets.map { |target| Bolt::Result.new(target, message: next_time.to_s) })
    }.be_called_times(2)
    expect_task('reboot')
      .with_params('timeout' => 5, 'message' => 'restarting')
      .always_return('status' => 'queued', 'timeout' => 0)

    result = run_plan('reboot', 'nodes' => 'foo,bar', 'reboot_delay' => 5, 'message' => 'restarting',
                                'disconnect_wait' => 1, 'reconnect_timeout' => 30, 'retry_interval' => 5)
    expect(result.value).to eq(nil)
  end

  it 'errors if last_boot_time is unavailable' do
    expect_task('reboot::last_boot_time').error_with('kind' => 'nope', 'msg' => 'could not')
    result = run_plan('reboot', 'nodes' => 'foo,bar')
    expect(result).not_to be_ok
  end
end
