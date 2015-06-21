module CanCan
  module Concepts
    module Utils
      module ResourceClass

        def resource_class
          case options[:class]
          when false  then resource_name.to_sym
          when nil    then namespaced_name.to_s.camelize.constantize
          when String then options[:class].constantize
          else options[:class]
          end
        end

        def resource_class_with_parent
          parent_resource ? {parent_resource => resource_class} : resource_class
        end

        def name_with_namespace
          [controller_namespace, resource_name.camelize].flatten.map(&:camelize).join('::').singularize.constantize
        rescue NameError
          resource_name
        end

        private

        def namespaced_name
          [controller_namespace, resource_name.camelize].flatten.map(&:camelize).join('::').singularize.constantize
        rescue NameError
          resource_name
        end

        def controller_namespace
          @controller.params[:controller].split('/')[0..-2]
        end

      end
    end
  end
end
