test_name "Install Reboot and Registry Module on Master" do
  on master, "git clone https://github.com/puppetlabs/puppetlabs-reboot /etc/puppet/modules/reboot"
  on master, "git clone https://github.com/puppetlabs/puppetlabs-registry /etc/puppet/modules/registry"

  with_puppet_running_on master, :main => { :verbose => true, :daemonize => true } do
    on agents, puppet("plugin download --server #{master}")
  end
end
