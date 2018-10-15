require 'spec_helper'

# We need to make sure that the methods we need still exist as Bolt may change
# a lot until it hits 1.0
describe 'Bolt::Executor', if: bolt_loaded? && tasks_available? do
  let(:executor) { Bolt::Executor.new }

  before(:each) do
    # There's no easy way to mock the config file location within the orchestrator client
    # so instead modify the class methods to use our fixtures
    OrchestratorClient::Config.any_instance.stubs(:puppetlabs_root).returns(fixtures_dir) # rubocop:disable RSpec/AnyInstance
    OrchestratorClient::Config.any_instance.stubs(:user_root).returns(fixtures_dir) # rubocop:disable RSpec/AnyInstance
  end

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

    describe 'Bolt::Transport::Orch' do
      let(:pcp) { transports['pcp'].value }

      it 'is able to generate us a connection' do
        expect(pcp).to respond_to(:get_connection)
        expect(pcp.get_connection('reboot_check')).to be_a(Bolt::Transport::Orch::Connection)
      end

      describe 'Bolt::Transport::Orch::Connection' do
        let(:connection) { pcp.get_connection('reboot_check') }

        it 'has the @client instance variable' do
          expect(connection.instance_variable_get('@client')).to be_a(OrchestratorClient)
        end

        describe 'OrchestratorClient' do
          let(:client) { connection.instance_variable_get('@client') }

          it 'allows us to make queries' do
            expect(client).to respond_to(:get)
          end
        end
      end
    end
  end
end
