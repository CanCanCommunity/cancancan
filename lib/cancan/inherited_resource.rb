module CanCan
  # For use with Inherited Resources
  class InheritedResource < ControllerResource # :nodoc:
    def loader
      @loader ||= InheritedResource::Loader.new(self, @params, @options)
    end

    def resource_base
      @controller.__send__(:end_of_association_chain)
    end

    class Loader < ControllerResource::Loader
      def load_resource_instance
        if @resource.parent?
          @resource.controller.__send__(:association_chain)
          @resource.controller.instance_variable_get("@#{@resource.instance_name}")
        elsif new_action?
          instance = @resource.controller.__send__(:build_resource)
          assign_attributes(instance)
        else
          @resource.controller.__send__(:resource)
        end
      end
    end
  end
end
