require 'spec_helper'

describe 'reboot::wait', if: bolt_loaded? && tasks_available? do
  let(:executor) { Bolt::Executor.new }

  around(:each) do |example|
    Puppet[:tasks] = true
    Puppet.features.stubs(:bolt?).returns(true)

    Puppet.override(bolt_executor: executor) do
      example.run
    end
  end

  context 'when using orchestrator' do
    let(:target) { Bolt::Target.new('example.puppet.com', 'protocol' => 'pcp') }

    it 'will run with a single Target' do
      # Mock the disconnection and reconnection of a client
      OrchestratorClient.any_instance.expects(:get).with('inventory/example.puppet.com').returns('connected' => true)
      OrchestratorClient.any_instance.expects(:get).with('inventory/example.puppet.com').returns('connected' => false)
      OrchestratorClient.any_instance.expects(:get).with('inventory/example.puppet.com').returns('connected' => true)

      is_expected.to run.with_params(target)
    end

    it 'will run with multiple targets' do
      targets = (1..100).map do |num|
        Bolt::Target.new("example#{num}.puppet.com", 'protocol' => 'pcp')
      end

      # Mock the disconnection and reconnection of all clients
      targets.each do |targ|
        OrchestratorClient.any_instance.expects(:get).with("inventory/#{targ.name}").returns('connected' => true)
        OrchestratorClient.any_instance.expects(:get).with("inventory/#{targ.name}").returns('connected' => false)
        OrchestratorClient.any_instance.expects(:get).with("inventory/#{targ.name}").returns('connected' => true)
      end

      is_expected.to run.with_params(targets)
    end
  end
end
