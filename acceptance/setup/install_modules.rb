test_name 'Install modules' do

  hosts.each do |host|
    on host, "mkdir -p #{host['distmoduledir']}"
    if host['platform'] =~ /windows/
      on host, "cd #{host['distmoduledir']} && git clone --branch 1.1.x --depth 1 git://github.com/puppetlabs/puppetlabs-registry.git registry"
      on host, "cd #{host['distmoduledir']} && git clone --branch 4.6.x --depth 1 git://github.com/puppetlabs/puppetlabs-stdlib.git stdlib"
    else
      on host, 'rm -rf /etc/puppetlabs/puppet/environments/production/modules/reboot'
      on host, puppet('module install puppetlabs/stdlib')
      on host, puppet('module install puppetlabs/registry')
    end
    copy_root_module_to(host, :module_name => 'reboot')
  end
end
