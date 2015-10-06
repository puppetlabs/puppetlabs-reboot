test_name 'Install modules' do

  hosts.each do |host|
    step 'Install Reboot Module Dependencies'
    on(host, puppet('module install puppetlabs-stdlib'))
    on(host, puppet('module install puppetlabs-registry'))

    copy_root_module_to(host, :module_name => 'reboot')
  end
end
