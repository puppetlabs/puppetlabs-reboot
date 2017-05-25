require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet'
require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

# We need this because the RAL uses 'should' as a method.  This
# allows us the same behaviour but with a different method name.
class Object
  alias :must :should
end
