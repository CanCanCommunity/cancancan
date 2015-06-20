module CanCan
  module Concepts
    class BuildResource < Base
      include Utils::Parent
      include Utils::ResourceClass
      include Utils::Actions

      def can_build?
        !parent? && new_actions.include?(@controller.params[:action].to_sym)
      end

      def build_resource
        accessor.set :instance, resource_class.new(resource_params || {})
        assign_attributes accessor.get(:instance)
      end

      def assign_attributes(resource)
        resource.send("#{parent_name}=", parent_resource) if options[:singleton] && parent_resource
        initial_attributes.each do |attr_name, value|
          resource.send("#{attr_name}=", value)
        end
        resource
      end

      def resource_params
        if parameters_require_sanitizing? && params_method.present?
          return case params_method
            when Symbol then @controller.send(params_method)
            when String then @controller.instance_eval(params_method)
            when Proc then params_method.call(@controller)
          end
        else
          resource_params_by_namespaced_name
        end
      end

      private

      def initial_attributes
        @controller.current_ability.attributes_for(@controller.params[:action].to_sym, resource_class).delete_if do |key, value|
          resource_params && resource_params.include?(key)
        end
      end

      def parameters_require_sanitizing?
        save_actions.include?(@controller.params[:action].to_sym) || resource_params_by_namespaced_name.present?
      end

      def resource_params_by_namespaced_name
        if options[:instance_name] && @controller.params.has_key?(extract_key(options[:instance_name]))
          @controller.params[extract_key(options[:instance_name])]
        elsif options[:class] && @controller.params.has_key?(extract_key(options[:class]))
          @controller.params[extract_key(options[:class])]
        else
          @controller.params[extract_key(namespaced_name)]
        end
      end

      def params_method
        params_methods.each do |method|
          return method if (method.is_a?(Symbol) && @controller.respond_to?(method, true)) || method.is_a?(String) || method.is_a?(Proc)
        end
        nil
      end

      def params_methods
        methods = ["#{@controller.params[:action]}_params".to_sym, "#{name}_params".to_sym, :resource_params]
        methods.unshift(options[:param_method]) if options[:param_method].present?
        methods
      end

      def extract_key(value)
         value.to_s.underscore.gsub('/', '_')
      end

      def resource_base
        @resource_base ||= ResourceClass.new @controller, @args
      end

      def accessor
        @accessor ||= Accessor.new @controller, @args
      end

    end
  end
end
