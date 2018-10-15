# Waits for nodes to reboot when executed from within a plan
#
# This function assumes that the nodes has just been told to reboot and
# therefore waits for it to disconnect and reconnect again.
#
# This has no valid use outside plans!
Puppet::Functions.create_function(:'reboot::wait') do
  # @param targets A TargetSpec containing all targets to wait for
  # @param params Extra parameters defined as a hash, valid keys are:
  #   disconnect_wait, reconnect_wait and retry_interval. All values should be
  #   integers and represent seconds.
  # @example Wait for some very slow nodes to reboot.
  #   reboot::wait($nodes, { 'disconnect_wait' => 120, 'reconnect_wait' => 600 })
  dispatch :wait do
    required_param 'Variant[Array,Target]', :targets
    optional_param 'Hash', :params
  end

  def wait(targets, params = { disconnect_wait: 20, reconnect_wait: 120, retry_interval: 1 })
    # Convert to array
    targets = [targets].flatten
    threads = []

    targets.each do |target|
      # We need to thread this so that we can check many nodes at once, it is
      # possible that this could cause performance issues but only at very
      # large scales and if you've just triggered 5000 nodes to reboot at once
      # you have bigger problems...
      threads << Thread.new do
        begin
          # If the target is connected in the beginning, wait for it to disconnect,
          # then wait for it to come back. Some server may take many minutes to shut
          # down.
          wait_until(params[:disconnect_wait], params[:retry_interval]) { !connected?(target) }

          # Once the target has disconnected, wait for it to come back
          wait_until(params[:reconnect_wait], params[:retry_interval]) { connected?(target) }
        rescue StandardError
          raise "Timed out waiting for #{target.name} to reboot"
        end
      end
    end

    threads.each(&:join)
  end

  def connected?(target)
    executor  = Puppet.lookup(:bolt_executor) { nil }
    transport = executor.transports[target.protocol].value

    case transport
    when Bolt::Transport::Orch
      # Check if a node is connected by hitting the /inventory endpoint
      connection = transport.get_connection('reboot_check')
      client     = connection.instance_variable_get('@client')
      inventory  = client.get("inventory/#{target.name}")
      inventory['connected']
    else
      # Currently only Orchestrator transport is implemented, anyone wanting
      # SSH or WinRM functionality should implement it here and submit a PR!
      raise "Don't know how to handle #{transport.class}"
    end
  end

  def wait_until(timeout = 10, retry_interval = 1)
    start = Time.now
    until yield
      raise 'Timeout' if (Time.now - start).to_i >= timeout
      sleep(retry_interval)
    end
  end
end
