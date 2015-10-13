test_name 'Install modules' do
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  staging = { :module_name => 'puppetlabs-reboot' }
  local = { :module_name => 'reboot', :source => proj_root }

  hosts.each do |host|
    step 'Install Reboot Module Dependencies'
    on(host, puppet('module install puppetlabs-stdlib'))
    on(host, puppet('module install puppetlabs-registry'))

    step 'Install Reboot Module'
    # in CI allow install from staging forge, otherwise from local
    install_dev_puppet_module_on(host, options[:forge_host] ? staging : local)
  end
end
