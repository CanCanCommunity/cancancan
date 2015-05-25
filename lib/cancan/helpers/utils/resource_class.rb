module CanCan
  module Helpers
    module Utils
      module ResourceClass

        def resource_class
          case options[:class]
          when false  then name.to_sym
          when nil    then namespaced_name.to_s.camelize.constantize
          when String then options[:class].constantize
          else options[:class]
          end
        end

        def name_with_namespace
          [controller_namespace, name.camelize].flatten.map(&:camelize).join('::').singularize.constantize
        rescue NameError
          name
        end

        private

        def namespaced_name
          [controller_namespace, name.camelize].flatten.map(&:camelize).join('::').singularize.constantize
        rescue NameError
          name
        end

        def controller_namespace
          @controller.params[:controller].split(/::|\//)[0..-2]
        end

      end
    end
  end
end