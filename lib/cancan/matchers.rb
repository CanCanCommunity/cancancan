rspec_module = defined?(RSpec::Core) ? 'RSpec' : 'Spec'  # for RSpec 1 compatability
Kernel.const_get(rspec_module)::Matchers.define :be_able_to do |*args|
  match do |ability|
    if args[0].is_a? Array
      args[0].all? do |action|
        ability.can?(action, args[1])
      endx
    else
      ability.can?(*args)
    end
  end

  failure_message_for_should do |ability|
    "expected to be able to #{args.map(&:inspect).join(" ")}"
  end

  failure_message_for_should_not do |ability|
    "expected not to be able to #{args.map(&:inspect).join(" ")}"
  end
end