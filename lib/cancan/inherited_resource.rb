module CanCan
  # For use with Inherited Resources
  class InheritedResource < ControllerResource # :nodoc:

    def initialize(controller, *args)
      super
      options = args.extract_options!
      name = args.first
      @load_resource = Concepts::LoadInheritedResource.new(controller, name, options)
    end

    def resource_base
      @controller.send :end_of_association_chain
    end
  end
end
