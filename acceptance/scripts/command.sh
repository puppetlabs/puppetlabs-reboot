#!/bin/bash

#Before you can execute this script you must clone the following repos in the cwd.
# *puppetlabs/puppet
# *puppetlabs/puppetlabs-reboot
export RUBYLIB=./puppet/acceptance/lib
beaker \
  --type git \
  --pre-suite puppet/acceptance/config/el6/setup/git/,puppetlabs-reboot/acceptance/setup/foss.rb \
  --config puppetlabs-reboot/acceptance/config/windows-2008r2-x86_64.cfg \
  --debug \
  --tests puppetlabs-reboot/acceptance/tests \
  --install PUPPET/master,FACTER/master,HIERA/master \
  --timeout 6000
