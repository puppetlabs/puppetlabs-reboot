require 'beaker-task_helper/inventory'
require 'bolt_spec/run'
require 'beaker-pe'
require 'beaker-puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'beaker/testmode_switcher'
require 'beaker/testmode_switcher/dsl'

run_puppet_install_helper
configure_type_defaults_on(hosts)

install_module_dependencies_on(hosts)

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
staging = { module_name: 'puppetlabs-reboot' }
local = { module_name: 'reboot', source: proj_root }

hosts.each do |host|
  # Install Reboot Module Dependencies
  on(host, puppet('module install puppetlabs-stdlib'))
  on(host, puppet('module install puppetlabs-registry'))

  # Install Reboot Module
  # in CI allow install from staging forge, otherwise from local
  install_dev_puppet_module_on(host, options[:forge_host] ? staging : local)
end

base_dir = File.dirname(File.expand_path(__FILE__))

RSpec.configure do |c|
  # Skip tasks tests unless Bolt is available
  c.filter_run_excluding(bolt: true) unless ENV['GEM_BOLT']

  # Make modules available locally for Bolt
  c.add_setting :module_path
  c.module_path = File.join(base_dir, 'fixtures', 'modules')
end

require 'rubygems' # this is necessary for ruby 1.8
require 'puppet/version'
WINDOWS_SHUTDOWN_ABORT = 'cmd /c shutdown /a'.freeze
# Some versions of ruby and puppet improperly report exit codes
# due to a ruby bug the correct error code 1116, is returned modulo 256 = 92
WINDOWS_SHUTDOWN_NOT_IN_PROGRESS = [1116, 1116 % 256].freeze

def shutdown_pid(agent)
  # code to get ps command taken from Facter 2.x implementation
  # as Facter 3.x is dropping the ps fact
  ps = case fact_on(agent, 'operatingsystem')
       when 'OpenWrt'
         'ps www'
       when 'FreeBSD', 'NetBSD', 'OpenBSD', 'Darwin', 'DragonFly'
         'ps auxwww'
       else
         'ps -ef'
       end
  # code to isolate PID adapted from Puppet service base provider
  on(agent, ps).stdout.each_line do |line|
    if line =~ %r{shutdown}
      return line.sub(%r{^\s+}, '').split(%r{\s+})[1]
    end
  end
  nil
end

def ensure_shutdown_not_scheduled(agent)
  sleep 5

  if windows_agents.include?(agent)
    on agent, WINDOWS_SHUTDOWN_ABORT, acceptable_exit_codes: WINDOWS_SHUTDOWN_NOT_IN_PROGRESS
  else
    pid = shutdown_pid(agent)
    if pid
      on(agent, "kill #{pid}", acceptable_exit_codes: [0])
      raise CommandFailure, "Host '#{agent}' had unexpected scheduled shutdown with PID #{pid}."
    end
  end
end

# If test is run on Debian 9 it does not seem possible to catch the shutdown command.
# As such code has beem implanted so that the loss of connection is caught instead.
def retry_shutdown_abort(agent, max_retries = 6)
  sleep 55 if (fact('operatingsystem') =~ %r{SLES} && (fact('operatingsystemrelease') =~ %r{^15\.}))
  i = 0
  while i < max_retries
    if windows_agents.include?(agent)
      result = on(agent, WINDOWS_SHUTDOWN_ABORT, acceptable_exit_codes: [0, WINDOWS_SHUTDOWN_NOT_IN_PROGRESS].flatten)
    elsif (fact('operatingsystem') =~ %r{RedHat} && fact('operatingsystemrelease') =~ %r{^8\.}) ||  # rubocop:disable Metrics/BlockNesting
          (fact('operatingsystem') =~ %r{CentOS} && fact('operatingsystemrelease') =~ %r{^8\.}) ||
          (fact('operatingsystem') =~ %r{Debian} && (fact('operatingsystemrelease') =~ %r{^9\.} || fact('operatingsystemrelease') =~ %r{^10\.})) ||
          (fact('operatingsystem') =~ %r{Ubuntu} && (fact('operatingsystemrelease') =~ %r{^16\.} || fact('operatingsystemrelease') =~ %r{^18\.}))
      result = on(agent, "shutdown -c", acceptable_exit_codes: [0])
    else
      begin
        pid = shutdown_pid(agent)
        result = on(agent, "kill #{pid}", acceptable_exit_codes: [0]) if pid
      rescue Beaker::Host::CommandFailure
        break if (fact('operatingsystem') =~ %r{SLES} && (fact('operatingsystemrelease') =~ %r{^15\.}))
        raise
      end
    end
    break if result.exit_code == 0

    warn("Reboot is not yet scheduled; sleeping for #{1 << i} seconds")
    sleep 1 << i
    i += 1
  end

  fail_test "Failed to abort shutdown on #{agent}" if i == max_retries
end

def windows_agents
  agents.select { |agent| agent['platform'].include?('windows') }
end

def posix_agents
  agents.reject { |agent| agent['platform'].include?('windows') }
end

def linux_agents
  agents.select { |agent| fact_on(agent, 'kernel') == 'Linux' }
end
