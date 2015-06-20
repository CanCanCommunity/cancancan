module CanCan
  module Concepts
    class LoadInheritedResource < LoadResource

      def load_resource_instance
        if parent?
          @controller.send :association_chain
          @controller.instance_variable_get("@#{instance_name}")
        elsif new_actions.include? @controller.params[:action].to_sym
          resource = @controller.build_resource
          assign_attributes(resource)
        else
          @controller.resource
        end
      end

    end
  end
end
