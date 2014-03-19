require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  if Puppet::Util::Platform.windows?
    config.output_stream = $stdout
    config.error_stream = $stderr
    config.formatters.each { |f| f.instance_variable_set(:@output, $stdout) }
  end
end

# We need this because the RAL uses 'should' as a method.  This
# allows us the same behaviour but with a different method name.
class Object
  alias :must :should
end
