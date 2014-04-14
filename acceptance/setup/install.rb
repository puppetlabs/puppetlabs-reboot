test_name "Installing Puppet Enterprise" do
  install_pe
  on master, puppet('module install puppetlabs/registry --modulepath /opt/puppet/share/puppet/modules')

  with_puppet_running_on master, :main => { :verbose => true, :daemonize => true } do
    on agents, puppet("plugin download --server #{master}")
  end
end
