test_name "Installing Puppet" do
  hosts.each do |host|
    version = ENV['PUPPET_VERSION'] || '3.6.2'
    download_url = ENV['WIN_DOWNLOAD_URL'] || 'http://downloads.puppetlabs.com/windows/'
    if host['platform'] =~ /windows/
      install_puppet_from_msi(host,
                              {
                                  :win_download_url => download_url,
                                  :version => version
                              })
    else
      install_puppet({:version => version, :default_action => 'gem_install'})
    end
  end
end
