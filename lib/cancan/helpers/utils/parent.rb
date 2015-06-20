module CanCan
  module Helpers
    module Utils
      module Parent

        def parent?
          if options.has_key?(:parent)
            options[:parent]
          else
            passed_name && passed_name != name_from_controller.to_sym
          end
        end

        def parent_resource
          parent_name && fetch_parent(parent_name)
        end

        private

        def parent_name
          options[:through] && [options[:through]].flatten.detect { |i| fetch_parent(i) }
        end

        def fetch_parent(name)
          if @controller.instance_variable_defined? "@#{name}"
            @controller.instance_variable_get("@#{name}")
          elsif @controller.respond_to?(name, true)
            @controller.send(name)
          end
        end

      end
    end
  end
end
