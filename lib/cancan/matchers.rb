rspec_module = defined?(RSpec::Core) ? 'RSpec' : 'Spec'  # for RSpec 1 compatability

if rspec_module == 'RSpec'
  require 'rspec/core'
  require 'rspec/expectations'
else
  ActiveSupport::Deprecation.warn("RSpec v1 will not be supported in the CanCanCan >= 2.0.0")
end

Kernel.const_get(rspec_module)::Matchers.define :be_able_to do |*args|
  match do |ability|
    ability.can?(*args)
  end

  failure_message_for_should do |ability|
    "expected to be able to #{args.map(&:inspect).join(" ")}"
  end

  failure_message_for_should_not do |ability|
    "expected not to be able to #{args.map(&:inspect).join(" ")}"
  end
end
