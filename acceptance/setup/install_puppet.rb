test_name "Installing Puppet" do
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  hosts.each do |host|
    version = ENV['PUPPET_VERSION'] || '3.6.2'
    download_url = ENV['WIN_DOWNLOAD_URL'] || 'http://downloads.puppetlabs.com/windows/'
    if host['platform'] =~ /windows/
      install_puppet_from_msi(host,
                              {
                                  :win_download_url => download_url,
                                  :version => version
                              })

      step "Install reboot to host"
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
