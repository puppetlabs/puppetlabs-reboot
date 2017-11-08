require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
begin
  require 'beaker/tasks/test'
rescue LoadError
  puts "Unable to load beaker/tasks/test for rake tasks"
end

# The acceptance tests for Reboot are written in standard beaker format however
# the preferred method is using beaker-rspec.  This rake task overrides the 
# default `beaker` task, which would normally use beaker-rspec, and instead
# invokes beaker directly.  This is only need while the module tests are migrated
# to the newer rspec-beaker format
task_exists = Rake.application.tasks.any? { |t| t.name == 'beaker' }
Rake::Task['beaker'].clear if task_exists
desc 'Run acceptance testing shim'
task :beaker do |t, args|
  beaker_cmd = "beaker --options-file acceptance/.beaker-pe.cfg --hosts #{ENV['BEAKER_setfile']} --tests acceptance/tests --keyfile #{ENV['BEAKER_keyfile']}"
  Kernel.system( beaker_cmd )
end

desc 'Run RSpec'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/{unit}/**/*.rb'
#  t.rspec_opts = ['--color']
end

desc 'Generate code coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

PuppetLint.configuration.fail_on_warnings
PuppetLint.configuration.send('disable_autoloader_layout')

# These lint exclusions are in puppetlabs_spec_helper but needs a version above 0.10.3 
# Line length test is 80 chars in puppet-lint 1.1.0
PuppetLint.configuration.send('disable_80chars')
# Line length test is 140 chars in puppet-lint 2.x
PuppetLint.configuration.send('disable_140chars')
