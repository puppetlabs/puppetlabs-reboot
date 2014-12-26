test_name 'Install modules' do
  hosts.each do |host|
    if host['platform'] =~ /windows/
      on host, "mkdir -p #{host['distmoduledir']}/reboot"
      on host, "cd #{host['distmoduledir']} && git clone --branch 1.0.x --depth 1 git://github.com/puppetlabs/puppetlabs-registry.git registry"
      on host, "cd #{host['distmoduledir']} && git clone --branch 4.3.2 --depth 1 git://github.com/puppetlabs/puppetlabs-stdlib.git stdlib"
    else
      on host, "mkdir -p #{host['distmoduledir']}/reboot"
      on host, puppet('module install puppetlabs/stdlib')
      on host, puppet('module install puppetlabs/registry')

    end
    install_dev_puppet_module_on(host, {:module_name => 'reboot'})
  end
end
