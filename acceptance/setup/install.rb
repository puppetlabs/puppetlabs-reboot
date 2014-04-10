test_name "Installing Puppet Enterprise" do
  install_pe
  step "Install required registry module"
  on master, puppet('module install puppetlabs/registry --modulepath /opt/puppet/share/puppet/modules')
end
