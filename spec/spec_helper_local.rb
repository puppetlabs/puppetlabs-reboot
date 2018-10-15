# We need this because the RAL uses 'should' as a method.  This
# allows us the same behaviour but with a different method name.
class Object
  alias must should
end

# Bolt may not available e.g. using an old version of ruby.
# Therefore we should safely attempt to load bolt and expose
# a method which can be used in tests to change behavior e.g.
# skip bolt tests if bolt is not loaded.
begin
  # Bolt prior to 1.0 had issues with localization therefore we need
  # Bolt 1.0 and above. Bolt 1.0 requires Puppet 6.0.0 and above. We
  # can't express this in the Gemfile so we need to guard loading here.
  # Only attempt to load bolt if the Puppet version constraint is met
  if Gem::Version.new(Puppet.version) >= Gem::Version.new('6.0.0')
    require 'bolt/executor'
    require 'bolt/target'
  end
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

def bolt_loaded?
  !defined?(Bolt).nil?
end

def tasks_available?
  # Tasks (--tasks) were introduced in Puppet Agent 5.4.0 (PUP-7898)
  Gem::Version.new(Puppet.version) >= Gem::Version.new('5.4.0')
end

def fixtures_dir
  @fixtures_dir_location ||= File.join(File.dirname(__FILE__), 'fixtures')
end
