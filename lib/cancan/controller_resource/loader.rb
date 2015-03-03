module CanCan
  class ControllerResource

    class Loader
      COLLECTION_ACTIONS = [:index]
      NEW_ACTIONS        = [:new, :create]
      SAVE_ACTIONS       = [:create, :update]

      def initialize(controller_resource, params, options)
        @resource = controller_resource
        @params   = params
        @options  = options
      end

      def load_resource
        if load_instance?
          @resource.resource_instance ||= load_resource_instance
        elsif load_collection?
          @resource.collection_instance ||= load_collection_instance
        end
      end

      def load_collection?
       resource_base.respond_to?(:accessible_by) && !current_ability.has_block?(@resource.authorization_action, @resource.resource_class)
      end

      def load_instance?
        @resource.parent? || member_action?
      end

      private

      def load_collection_instance
       resource_base.accessible_by(current_ability, @resource.authorization_action)
      end

      def load_resource_instance
        if !@resource.parent? && new_action?
          build_resource_instance
        elsif id_param || @options[:singleton]
          find_resource_instance
        end
      end

      def find_resource_instance
        if @options[:singleton] && @resource.parent_resource.respond_to?(@resource.name)
          return @resource.parent_resource.__send__(@resource.name)
        end

        return adapter.find(resource_base, id_param) unless @options.has_key?(:find_by)
        find_by_attribute = @options[:find_by]

        if resource_base.respond_to?("find_by_#{find_by_attribute}!")
         resource_base.__send__("find_by_#{find_by_attribute}!", id_param)
        elsif resource_base.respond_to?(:find_by)
         resource_base.__send__(:find_by, {find_by_attribute.to_sym => id_param})
        else
         resource_base.__send__(find_by_attribute, id_param)
        end
      end

      def adapter
        ModelAdapters::AbstractAdapter.adapter_class(@resource.resource_class)
      end

      def build_resource_instance
        instance = resource_base.new(resource_params || {})
        assign_attributes(instance)
      end

      def assign_attributes(instance)
        if @options[:singleton] && @resource.parent_resource
          instance.__send__("#{@resource.parent_tuple.first}=", @resource.parent_resource)
        end

        current_ability.attributes_for(@resource.controller_action, @resource.resource_class).each do |key, value|
          unless resource_params && resource_params.include?(key)
            instance.__send__("#{key}=", value)
          end
        end
        instance
      end

      # The object that methods (such as "find", "new" or "build") are called on.
      # If the :through option is passed it will go through an association on that instance.
      # If the :shallow option is passed it will use the resource_class if there's no parent
      # If the :singleton option is passed it won't use the association because it needs to be handled later.
      def resource_base
        return @resource.resource_class unless @options.has_key?(:through)

        if @resource.parent_resource
          through_association = @options.fetch(:through_association) { @resource.name.to_s.pluralize }
          base = @options[:singleton] ? @resource.resource_class : @resource.parent_resource.__send__(through_association)
          base = base.scoped if base.respond_to?(:scoped) && defined?(ActiveRecord) && ActiveRecord::VERSION::MAJOR == 3
          base
        elsif @options[:shallow]
          @resource.resource_class
        else
          raise AccessDenied.new(nil, @resource.authorization_action, @resource.resource_class) # maybe this should be a record not found error instead?
        end
      end

      def resource_params
        unless parameters_require_sanitizing? && params_method.present?
          return resource_params_by_namespaced_name
        end

        case params_method
        when Symbol then @resource.controller.__send__(params_method)
        when String then @resource.controller.instance_eval(params_method)
        when Proc   then params_method.call(@resource.controller)
        end
      end

      def parameters_require_sanitizing?
        save_action? || resource_params_by_namespaced_name.present?
      end

      def resource_params_by_namespaced_name
        [:instance_name, :class].each do |param|
          option = @options[param]
          return @params[extract_key(option)] if option && @params.has_key?(extract_key(option))
        end
        @params[extract_key(@resource.namespaced_name)]
      end

      def params_method
        methods = ["#{@resource.controller_action}_params".to_sym, "#{@resource.name}_params".to_sym, :resource_params]
        methods.unshift(@options[:param_method]) if @options.has_key?(:param_method)

        methods.detect do |method|
          (method.is_a?(Symbol) && @resource.controller.respond_to?(method, true)) || method.is_a?(String) || method.is_a?(Proc)
        end
      end

      def member_action?
        return true if new_action? || @options[:singleton]
        id_param = @options.fetch(:id_param, :id)
        @params.has_key?(id_param) && !collection_action?
      end

      def id_param
        key = @options.fetch(:id_param) { @resource.parent? ? :"#{@resource.name}_id" : :id }
        value = @params[key]
        value && value.to_s
      end

      def collection_action?
        actions = COLLECTION_ACTIONS + [*@options[:collection]]
        actions.include?(@resource.controller_action)
      end

      def new_action?
        actions = NEW_ACTIONS + [*@options[:new]]
        actions.include?(@resource.controller_action)
      end

      def save_action?
        SAVE_ACTIONS.include?(@resource.controller_action)
      end

      def current_ability
        @resource.controller.__send__(:current_ability)
      end

      def extract_key(value)
        value.to_s.underscore.gsub('/', '_')
      end
    end

  end
end
