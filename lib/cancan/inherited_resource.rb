module CanCan
  # For use with Inherited Resources
  class InheritedResource < ControllerResource # :nodoc:

    def initialize(controller, *args)
      super
      @load_resource = Concepts::LoadInheritedResource.new(controller, args.dup)
    end

    def resource_base
      @controller.send :end_of_association_chain
    end
  end
end
