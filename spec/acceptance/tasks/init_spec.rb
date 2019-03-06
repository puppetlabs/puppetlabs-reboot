require 'spec_helper_acceptance'
require 'time'

describe 'reboot task', bolt: true do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def module_path
    RSpec.configuration.module_path
  end

  def config
    { 'modulepath' => module_path }
  end

  def inventory
    hosts_to_inventory
  end

  let(:tm) { 60 }

  it 'reports the last boot time' do
    results = run_task('reboot::last_boot_time', 'agent', {}, config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['_output']).to be
    end
  end

  it 'reboots a target' do
    results = run_task('reboot', 'agent', { 'timeout' => tm }, config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['status']).to eq('queued')
      expect(res['result']['timeout']).to eq(tm)
    end

    agents.each { |agent| retry_shutdown_abort(agent) }
  end

  it 'accepts a message' do
    results = run_task('reboot', 'agent', { 'timeout' => tm, 'message' => 'Bolt is rebooting the computer' },
                       config: config, inventory: inventory)
    results.each do |res|
      expect(res).to include('status' => 'success')
      expect(res['result']['status']).to eq('queued')
      expect(res['result']['timeout']).to eq(tm)
    end

    agents.each { |agent| retry_shutdown_abort(agent) }
  end
end
