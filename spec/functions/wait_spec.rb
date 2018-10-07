require 'spec_helper'

# We need to make sure that the methods we need still exist as Bolt may change
# a lot until it hits 1.0
describe Bolt::Executor do
  let(:executor) { Bolt::Executor.new }

  it 'returns transports' do
    expect(executor).to respond_to(:transports)
  end

  describe 'transports' do
    let(:transports) { executor.transports }

    it 'returns a hash' do
      expect(transports).to be_a(Hash)
    end

    it 'has a pcp key' do
      expect(transports).to have_key('pcp')
    end

    it 'is able to return us a Bolt::Transport::Orch object' do
      expect(transports['pcp']).to respond_to(:value)
      expect(transports['pcp'].value).to be_a(Bolt::Transport::Orch)
    end

    describe Bolt::Transport::Orch do
      let(:pcp) { transports['pcp'].value }

      it 'is able to generate us a connection' do
        expect(pcp).to respond_to(:get_connection)
        expect(pcp.get_connection('reboot_check')).to be_a(Bolt::Transport::Orch::Connection)
      end

      describe Bolt::Transport::Orch::Connection do
        let(:connection) { pcp.get_connection('reboot_check') }

        it 'has the @client instance variable' do
          expect(connection.instance_variable_get('@client')).to be_a(OrchestratorClient)
        end

        describe OrchestratorClient do
          let(:client) { connection.instance_variable_get('@client') }

          it 'allows us to make queries' do
            expect(client).to respond_to(:get)
          end
        end
      end
    end
  end
end

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
