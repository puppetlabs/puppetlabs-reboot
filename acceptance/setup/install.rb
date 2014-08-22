test_name "Installing Puppet Enterprise" do
  install_pe

  #remove bundled version of reboot before testing attempting to push out test version
  on master, puppet('module uninstall puppetlabs/reboot --force')

  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  agents.each do |host|
    if host['platform'] =~ /windows/i
      on host, "mkdir -p #{host['distmoduledir']}/reboot"
      result = on host, "echo #{host['distmoduledir']}/reboot"
      target = result.raw_output.chomp
      %w(lib manifests metadata.json).each do |file|
        scp_to host, "#{proj_root}/#{file}", "#{target}"
      end
      on host, "cd #{host['distmoduledir']} && git clone --branch 1.0.x --depth 1 git://github.com/puppetlabs/puppetlabs-registry.git registry"
      on host, "cd #{host['distmoduledir']} && git clone --branch 4.3.2 --depth 1 git://github.com/puppetlabs/puppetlabs-stdlib.git stdlib"
    end
  end
end
