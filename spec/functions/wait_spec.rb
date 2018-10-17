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

  before(:each) do
    # There's no easy way to mock the config file location within the orchestrator client
    # so instead modify the class methods to use our fixtures
    OrchestratorClient::Config.any_instance.stubs(:puppetlabs_root).returns(fixtures_dir)
    OrchestratorClient::Config.any_instance.stubs(:user_root).returns(fixtures_dir)
  end

  context 'when using orchestrator' do
    let(:target) { Bolt::Target.new('example.puppet.com', 'protocol' => 'pcp') }

    it 'will run with a single Target' do
      Puppet::Pops::Functions::Function.any_instance.stubs(:call_function).with('get_targets', target).returns([target])

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

      Puppet::Pops::Functions::Function.any_instance.stubs(:call_function).with('get_targets', targets).returns(targets)

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
